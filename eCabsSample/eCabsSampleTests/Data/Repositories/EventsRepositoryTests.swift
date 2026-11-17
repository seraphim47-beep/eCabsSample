//
//  EventsRepositoryTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//

import XCTest
@testable import eCabsSample

final class EventsRepositoryTests: XCTestCase {

    /// Ensures initial events are correctly fetched and stored.
    @MainActor
    func testFetchEventsStoresInitialEvents() async throws { // Prima risposta e cache
        let mock = MockGitHubAPIClient(responses: [
            .success(
                makeResponse(
                    events: [makeDTO(id: "1")],
                    etag: "etag-1",
                    pollInterval: 60
                )
            )
        ])

        let sut = makeRepository(apiClient: mock)

        let result = try await sut.fetchEvents()

        XCTAssertEqual(result.events.count, 1)
        XCTAssertEqual(result.events.first?.id, "1")
        XCTAssertEqual(result.pollInterval, 60)
        XCTAssertTrue(result.wasModified)
    }

    /// Validates event merging and deduplication.
    @MainActor
    func testFetchEventsMergesNewEventsAndRemovesDuplicates() async throws { // Merge e aggiornamento duplicati
        let mock = MockGitHubAPIClient(responses: [
            .success(
                makeResponse(
                    events: [
                        makeDTO(id: "1", date: "2026-11-15T10:00:00Z")
                    ],
                    etag: "etag-1"
                )
            ),
            .success(
                makeResponse(
                    events: [
                        makeDTO(id: "1", type: "WatchEvent", date: "2026-11-15T11:00:00Z"),
                        makeDTO(id: "2", date: "2026-11-15T12:00:00Z")
                    ],
                    etag: "etag-2"
                )
            )
        ])

        let sut = makeRepository(apiClient: mock)

        _ = try await sut.fetchEvents()
        let result = try await sut.fetchEvents()

        XCTAssertEqual(result.events.count, 2)
        XCTAssertEqual(result.events.map(\.id), ["2", "1"])
        XCTAssertEqual(result.events.last?.type, "WatchEvent")
        XCTAssertTrue(result.wasModified)
    }

    /// Ensures cached data is preserved when the server returns HTTP 304.
    @MainActor
    func testFetchEventsKeepsCacheWhenResponseIsNotModified() async throws {
        let mock = MockGitHubAPIClient(responses: [
            .success(
                makeResponse(
                    events: [makeDTO(id: "1")],
                    etag: "etag-1"
                )
            ),
            .success(
                GitHubAPIResponse(
                    result: .notModified,
                    etag: "etag-1",
                    pollInterval: 60
                )
            )
        ])

        let sut = makeRepository(apiClient: mock)

        let firstResult = try await sut.fetchEvents()
        let secondResult = try await sut.fetchEvents()

        let firstEventIDs = firstResult.events.map(\.id)
        let secondEventIDs = secondResult.events.map(\.id)
        let secondEventCount = secondResult.events.count
        let secondEventID = secondResult.events.first?.id
        let wasModified = secondResult.wasModified

        XCTAssertEqual(secondEventCount, 1)
        XCTAssertEqual(secondEventID, "1")
        XCTAssertFalse(wasModified)
        XCTAssertEqual(secondEventIDs, firstEventIDs)
    }

    /// Validates ETag updates and preservation.
    func testFetchEventsPreservesAndUpdatesETag() async throws { // Conservazione e aggiornamento ETag
        let mock = MockGitHubAPIClient(responses: [
            .success(
                makeResponse(
                    events: [makeDTO(id: "1")],
                    etag: "etag-1"
                )
            ),
            .success(
                GitHubAPIResponse(
                    result: .notModified,
                    etag: "etag-2",
                    pollInterval: 60
                )
            ),
            .success(
                GitHubAPIResponse(
                    result: .notModified,
                    etag: nil,
                    pollInterval: 60
                )
            )
        ])

        let sut = makeRepository(apiClient: mock)

        _ = try await sut.fetchEvents()
        _ = try await sut.fetchEvents()
        _ = try await sut.fetchEvents()

        let requestedETags = await mock.requestedETags()

        XCTAssertEqual(
            requestedETags,
            [nil, "etag-1", "etag-2"]
        )
    }

    /// Ensures API client errors are correctly propagated
    func testFetchEventsPropagatesAPIError() async { // Propagazione degli errori
        let mock = MockGitHubAPIClient(responses: [
            .failure(.networkError)
        ])

        let sut = makeRepository(apiClient: mock)

        do {
            _ = try await sut.fetchEvents()
            XCTFail("Expected network error")
        } catch let error as APIError {
            if case .networkError = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected APIError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Helpers

    private func makeRepository(apiClient: MockGitHubAPIClient) -> EventsRepository {
        EventsRepository(
            apiClient: apiClient,
            mergeEventsUseCase: MergeEventsUseCase()
        )
    }

    private func makeResponse(
        events: [GitHubEventDTO],
        etag: String? = nil,
        pollInterval: Int = 60
    ) -> GitHubAPIResponse {
        GitHubAPIResponse(
            result: .success(events),
            etag: etag,
            pollInterval: pollInterval
        )
    }

    private func makeDTO(
        id: String,
        type: String = "PushEvent",
        date: String = "2026-11-15T10:00:00Z"
    ) -> GitHubEventDTO {
        let payload = """
        {
            "id": "\(id)",
            "type": "\(type)",
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
            "payload": {
                "action": "started"
            },
            "public": true,
            "created_at": "\(date)"
        }
        """

        return try! JSONDecoder().decode(
            GitHubEventDTO.self,
            from: Data(payload.utf8)
        )
    }
}

// MARK: - Mock

private actor MockGitHubAPIClient: GitHubAPIClientProtocol {

    private var responses: [Result<GitHubAPIResponse, APIError>]
    private var etags: [String?] = []

    init(responses: [Result<GitHubAPIResponse, APIError>]) {
        self.responses = responses
    }

    func fetchEvents(etag: String?) async throws -> GitHubAPIResponse {
        etags.append(etag)

        guard !responses.isEmpty else {
            throw APIError.invalidResponse
        }

        return try responses.removeFirst().get()
    }

    func requestedETags() -> [String?] {
        etags
    }
}
