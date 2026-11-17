//
//  GitHubAPIClientTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//

import XCTest
@testable import eCabsSample

final class GitHubAPIClientTests: XCTestCase {

    override func tearDown() {
        URLProtocolMock.requestHandler = nil
        super.tearDown()
    }

    /// Validates event decoding for an HTTP 200 response.
    @MainActor
    func testFetchEventsReturnsEventsOnHTTP200() async throws {
        URLProtocolMock.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Accept"),
                "application/vnd.github+json"
            )

            return Self.response(
                statusCode: 200,
                headers: [
                    "ETag": "etag-123",
                    "X-Poll-Interval": "45"
                ],
                data: Self.validJSON
            )
        }

        let sut = makeSUT()
        let result = try await sut.fetchEvents(etag: nil)

        guard case .success(let events) = result.result else {
            return XCTFail("Expected successful response")
        }

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.id, "123")
        XCTAssertEqual(result.etag, "etag-123")
        XCTAssertEqual(result.pollInterval, 45)
    }

    ///  Validates Not Modified response handling.
    @MainActor
    func testFetchEventsReturnsNotModifiedOnHTTP304() async throws {
        URLProtocolMock.requestHandler = { _ in
            Self.response(statusCode: 304)
        }

        let sut = makeSUT()
        let result = try await sut.fetchEvents(etag: "etag-123")

        guard case .notModified = result.result else {
            return XCTFail("Expected notModified response")
        }

        XCTAssertEqual(result.etag, "etag-123")
        XCTAssertEqual(result.pollInterval, 60)
    }

    /// Ensures the ETag is sent in the`If-None-Match` header.
    func testFetchEventsSendsETagHeader() async throws {
        URLProtocolMock.requestHandler = { request in
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "If-None-Match"),
                "etag-previous"
            )

            return Self.response(statusCode: 304)
        }

        let sut = makeSUT()

        _ = try await sut.fetchEvents(etag: "etag-previous")
    }

    /// Validates the default interval when the header is missing.
    @MainActor
    func testFetchEventsUsesDefaultPollIntervalWhenHeaderIsMissing() async throws {
        URLProtocolMock.requestHandler = { _ in
            Self.response(
                statusCode: 200,
                data: Self.validJSON
            )
        }

        let sut = makeSUT()
        let result = try await sut.fetchEvents(etag: nil)

        XCTAssertEqual(result.pollInterval, 60)
    }

    /// Validates the default interval when the received value is  invalid.
    @MainActor
    func testFetchEventsUsesDefaultPollIntervalWhenHeaderIsInvalid() async throws {
        URLProtocolMock.requestHandler = { _ in
            Self.response(
                statusCode: 200,
                headers: ["X-Poll-Interval": "invalid"],
                data: Self.validJSON
            )
        }

        let sut = makeSUT()
        let result = try await sut.fetchEvents(etag: nil)

        XCTAssertEqual(result.pollInterval, 60)
    }

    /// Validates handling of undecodable JSON.
    func testFetchEventsThrowsDecodingErrorForInvalidJSON() async {
        URLProtocolMock.requestHandler = { _ in
            Self.response(
                statusCode: 200,
                data: Data("invalid json".utf8)
            )
        }

        let sut = makeSUT()

        do {
            _ = try await sut.fetchEvents(etag: nil)
            XCTFail("Expected decoding error")
        } catch let error as APIError {
            guard case .decodingError = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Validates HTTP error handling.
    func testFetchEventsThrowsHTTPError() async {
        URLProtocolMock.requestHandler = { _ in
            Self.response(statusCode: 500)
        }

        let sut = makeSUT()

        do {
            _ = try await sut.fetchEvents(etag: nil)
            XCTFail("Expected HTTP error")
        } catch let error as APIError {
            guard case .httpError(500) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Validates HTTP 429 rate limit handling and the `Retry-After` header.
    func testFetchEventsHandlesRateLimit429() async {
        URLProtocolMock.requestHandler = { _ in
            Self.response(
                statusCode: 429,
                headers: ["Retry-After": "30"]
            )
        }

        let sut = makeSUT()

        do {
            _ = try await sut.fetchEvents(etag: nil)
            XCTFail("Expected rate limit error")
        } catch let error as APIError {
            guard case .rateLimited(let resetDate) = error else {
                return XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(resetDate)

            if let resetDate {
                let delay = resetDate.timeIntervalSinceNow
                XCTAssertTrue((29...30).contains(Int(ceil(delay))))
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Validates HTTP 403 rate limit handling using GhitHub reset  headers
    func testFetchEventsHandlesRateLimit403() async {
        let resetTimestamp = Date().addingTimeInterval(120).timeIntervalSince1970

        URLProtocolMock.requestHandler = { _ in
            Self.response(
                statusCode: 403,
                headers: [
                    "X-RateLimit-Remaining": "0",
                    "X-RateLimit-Reset": String(Int(resetTimestamp))
                ]
            )
        }

        let sut = makeSUT()

        do {
            _ = try await sut.fetchEvents(etag: nil)
            XCTFail("Expected rate limit error")
        } catch let error as APIError {
            guard case .rateLimited(let resetDate) = error else {
                return XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(resetDate)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> GitHubAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]

        let session = URLSession(configuration: configuration)

        return GitHubAPIClient(session: session)
    }

    private static func response(
        statusCode: Int,
        headers: [String: String] = [:],
        data: Data = Data()
    ) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.github.com/events")!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!

        return (response, data)
    }

    private static let validJSON = Data("""
    [
        {
            "id": "123",
            "type": "PushEvent",
            "actor": {
                "id": 1,
                "login": "test-user",
                "display_login": "test-user",
                "avatar_url": "https://github.com/images/test.png"
            },
            "repo": {
                "id": 10,
                "name": "test/repository",
                "url": "https://api.github.com/repos/test/repository"
            },
            "payload": {},
            "public": true,
            "created_at": "2026-11-15T10:00:00Z"
        }
    ]
    """.utf8)
}

// MARK: - URLProtocol Mock

private final class URLProtocolMock: URLProtocol {

    nonisolated(unsafe) static var requestHandler: ((
        URLRequest
    ) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(
                self,
                didFailWithError: APIError.networkError
            )
            return
        }

        do {
            let (response, data) = try handler(request)

            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )

            if !data.isEmpty {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)

        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
