//
//  AvatarLoaderTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//



import XCTest
import UIKit
@testable import eCabsSample

@MainActor
final class AvatarLoaderTests: XCTestCase {

    override func tearDown() {
        AvatarURLProtocolMock.reset()
        super.tearDown()
    }

    func testLoadImageReturnsImageForSuccessfulResponse() async {
        AvatarURLProtocolMock.requestHandler = { _ in
            .success((200, self.makeImageData()))
        }

        let sut = makeSUT()
        let url = makeURL()

        let image = await sut.loadImage(from: url)

        XCTAssertNotNil(image)
        XCTAssertEqual(AvatarURLProtocolMock.requestCount, 1)
    }

    func testLoadImageUsesCacheForRepeatedRequests() async {
        AvatarURLProtocolMock.requestHandler = { _ in
            .success((200, self.makeImageData()))
        }

        let sut = makeSUT()
        let url = makeURL()

        let firstImage = await sut.loadImage(from: url)
        let secondImage = await sut.loadImage(from: url)

        XCTAssertNotNil(firstImage)
        XCTAssertNotNil(secondImage)
        XCTAssertEqual(AvatarURLProtocolMock.requestCount, 1)
    }

    func testLoadImageSharesConcurrentRequests() async {
        AvatarURLProtocolMock.responseDelay = 0.2
        AvatarURLProtocolMock.requestHandler = { _ in
            .success((200, self.makeImageData()))
        }

        let sut = makeSUT()
        let url = makeURL()

        async let firstImage = sut.loadImage(from: url)
        async let secondImage = sut.loadImage(from: url)

        let (first, second) = await (firstImage, secondImage)

        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
        XCTAssertEqual(AvatarURLProtocolMock.requestCount, 1)
    }

    func testLoadImageReturnsNilForHTTPError() async {
        AvatarURLProtocolMock.requestHandler = { _ in
            .success((404, Data()))
        }

        let sut = makeSUT()
        let image = await sut.loadImage(from: makeURL())

        XCTAssertNil(image)
        XCTAssertEqual(AvatarURLProtocolMock.requestCount, 1)
    }

    func testLoadImageReturnsNilForInvalidImageData() async {
        AvatarURLProtocolMock.requestHandler = { _ in
            .success((200, Data("invalid image".utf8)))
        }

        let sut = makeSUT()
        let image = await sut.loadImage(from: makeURL())

        XCTAssertNil(image)
    }

    func testLoadImageReturnsNilForNetworkError() async {
        AvatarURLProtocolMock.requestHandler = { _ in
            .failure(URLError(.notConnectedToInternet))
        }

        let sut = makeSUT()
        let image = await sut.loadImage(from: makeURL())

        XCTAssertNil(image)
    }

    // MARK: - Helpers

    private func makeSUT() -> AvatarLoader {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [AvatarURLProtocolMock.self]

        let session = URLSession(configuration: configuration)

        return AvatarLoader(session: session)
    }

    private func makeURL() -> URL {
        URL(string: "https://example.com/avatar.png")!
    }

    private func makeImageData() -> Data {
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: 2, height: 2)
        )

        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }.pngData()!
    }
}

// MARK: - URLProtocol Mock

private final class AvatarURLProtocolMock: URLProtocol {

    nonisolated(unsafe) static var requestHandler: ((
        URLRequest
    ) -> Result<(Int, Data), Error>)?

    nonisolated(unsafe) static var requestCount = 0
    nonisolated(unsafe) static var responseDelay: TimeInterval = 0

    private static let lock = NSLock()

    static func reset() {
        lock.lock()
        requestHandler = nil
        requestCount = 0
        responseDelay = 0
        lock.unlock()
    }

    private static func performRequest(
        _ request: URLRequest
    ) -> (Result<(Int, Data), Error>, TimeInterval) {
        lock.lock()
        defer { lock.unlock() }

        requestCount += 1

        let result = requestHandler?(
            request
        ) ?? .failure(URLError(.badServerResponse))

        return (result, responseDelay)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let (result, delay) = Self.performRequest(request)

        DispatchQueue.global().asyncAfter(
            deadline: .now() + delay
        ) { [weak self] in
            guard let self else { return }

            switch result {
            case .success(let (statusCode, data)):
                let response = HTTPURLResponse(
                    url: self.request.url!,
                    statusCode: statusCode,
                    httpVersion: "HTTP/1.1",
                    headerFields: nil
                )!

                self.client?.urlProtocol(
                    self,
                    didReceive: response,
                    cacheStoragePolicy: .notAllowed
                )

                if !data.isEmpty {
                    self.client?.urlProtocol(self, didLoad: data)
                }

                self.client?.urlProtocolDidFinishLoading(self)

            case .failure(let error):
                self.client?.urlProtocol(
                    self,
                    didFailWithError: error
                )
            }
        }
    }

    override func stopLoading() {}
}
