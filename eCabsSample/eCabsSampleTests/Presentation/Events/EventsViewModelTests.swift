//
//  EventsViewModelTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//



import XCTest
@testable import eCabsSample

@MainActor
final class EventsViewModelTests: XCTestCase {

    func testLoadEventsUpdatesViewModelState() async {
        let events = [
            makeEvent(id: "1", type: "PushEvent"),
            makeEvent(id: "2", type: "IssuesEvent")
        ]

        let repository = MockEventsRepository(responses: [
            .success(
                EventsFetchResult(
                    events: events,
                    pollInterval: 60,
                    wasModified: true
                )
            )
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()
        sut.stopPolling()

        XCTAssertEqual(sut.events.count, 2)
        XCTAssertEqual(sut.currentPollInterval, 60)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertNotNil(sut.lastUpdatedAt)
    }

    func testLoadEventsHandlesEmptyResponse() async {
        let repository = MockEventsRepository(responses: [
            .success(
                EventsFetchResult(
                    events: [],
                    pollInterval: 60,
                    wasModified: true
                )
            )
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()
        sut.stopPolling()

        XCTAssertTrue(sut.events.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testUpdateFiltersReturnsOnlySelectedEventTypes() async {
        let events = [
            makeEvent(id: "1", type: "PushEvent"),
            makeEvent(id: "2", type: "IssuesEvent"),
            makeEvent(id: "3", type: "WatchEvent"),
            makeEvent(id: "4", type: "PushEvent")
        ]

        let repository = MockEventsRepository(responses: [
            .success(
                EventsFetchResult(
                    events: events,
                    pollInterval: 60,
                    wasModified: true
                )
            )
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()
        sut.stopPolling()

        sut.updateFilters(["PushEvent"])

        XCTAssertEqual(sut.events.map(\.id), ["1", "4"])
        XCTAssertTrue(sut.events.allSatisfy { $0.type == "PushEvent" })
    }

    func testUpdateFiltersWithEmptySelectionReturnsAllEvents() async {
        let events = [
            makeEvent(id: "1", type: "PushEvent"),
            makeEvent(id: "2", type: "IssuesEvent")
        ]

        let repository = MockEventsRepository(responses: [
            .success(
                EventsFetchResult(
                    events: events,
                    pollInterval: 60,
                    wasModified: true
                )
            )
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()
        sut.stopPolling()

        sut.updateFilters([])

        XCTAssertEqual(sut.events.count, 2)
    }

    func testLoadEventsHandlesNetworkError() async {
        let repository = MockEventsRepository(responses: [
            .failure(.networkError)
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()

        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.events.isEmpty)
    }

    func testLoadEventsUpdatesAvailableEventTypes() async {
        let events = [
            makeEvent(id: "1", type: "PushEvent"),
            makeEvent(id: "2", type: "IssuesEvent"),
            makeEvent(id: "3", type: "WatchEvent")
        ]

        let repository = MockEventsRepository(responses: [
            .success(
                EventsFetchResult(
                    events: events,
                    pollInterval: 60,
                    wasModified: true
                )
            )
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()
        sut.stopPolling()

        XCTAssertEqual(sut.availableEventTypes.count, 5)
        XCTAssertTrue(sut.availableEventTypes.contains("PushEvent"))
        XCTAssertTrue(sut.availableEventTypes.contains("IssuesEvent"))
        XCTAssertTrue(sut.availableEventTypes.contains("WatchEvent"))
    }
    
    func testLoadEventsHandlesRateLimitWithResetDate() async {
        let resetDate = Date().addingTimeInterval(120)

        let repository = MockEventsRepository(responses: [
            .failure(.rateLimited(resetDate: resetDate))
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()
        sut.stopPolling()

        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains(
            String(localized: "error.rate_limit_until")
        ) == false)

        XCTAssertGreaterThanOrEqual(sut.currentPollInterval, 1)
        XCTAssertLessThanOrEqual(sut.currentPollInterval, 120)
    }
    
    func testLoadEventsHandlesRateLimitWithoutResetDate() async {
        let repository = MockEventsRepository(responses: [
            .failure(.rateLimited(resetDate: nil))
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()
        sut.stopPolling()

        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(
            sut.errorMessage,
            String(localized: "error.rate_limit")
        )
        XCTAssertEqual(sut.currentPollInterval, 60)
    }
    
    func testLoadEventsPreservesPreviouslyLoadedEventsAfterError() async {
        let events = [
            makeEvent(id: "1", type: "PushEvent"),
            makeEvent(id: "2", type: "IssuesEvent")
        ]

        let repository = MockEventsRepository(responses: [
            .success(
                EventsFetchResult(
                    events: events,
                    pollInterval: 60,
                    wasModified: true
                )
            ),
            .failure(.networkError)
        ])

        let sut = makeViewModel(repository: repository)

        await sut.loadEvents()
        sut.stopPolling()

        let previousIDs = sut.events.map(\.id)

        await sut.loadEvents()
        sut.stopPolling()

        XCTAssertEqual(sut.events.map(\.id), previousIDs)
        XCTAssertEqual(sut.events.count, 2)
        XCTAssertEqual(sut.errorMessage, String(localized: "error.network"))
    }

    // MARK: - Helpers

    private func makeViewModel(repository: MockEventsRepository) -> EventsViewModel {
        EventsViewModel(repository: repository)
    }

    private func makeEvent(
        id: String,
        type: String
    ) -> GitHubEvent {
        GitHubEvent(
            id: id,
            type: type,
            actor: .init(
                id: 1,
                login: "test-user",
                displayLogin: nil,
                avatarURL: nil
            ),
            repository: .init(
                id: 1,
                name: "test/repository",
                url: URL(string: "https://github.com/test/repository")!
            ),
            payload: .unknown(.null),
            isPublic: true,
            createdAt: Date(timeIntervalSince1970: 1)
        )
    }
}

// MARK: - Mock Repository

private actor MockEventsRepository: EventsRepositoryProtocol {

    private var responses: [Result<EventsFetchResult, APIError>]

    init(responses: [Result<EventsFetchResult, APIError>]) {
        self.responses = responses
    }

    func fetchEvents() async throws -> EventsFetchResult {
        guard !responses.isEmpty else {
            throw APIError.invalidResponse
        }

        return try responses.removeFirst().get()
    }
}
