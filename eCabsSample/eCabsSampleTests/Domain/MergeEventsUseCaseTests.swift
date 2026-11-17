//
//  MergeEventsUseCaseTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//



import XCTest
@testable import eCabsSample

final class MergeEventsUseCaseTests: XCTestCase {

    private let sut = MergeEventsUseCase()

    func testExecuteMergesExistingAndIncomingEvents() {
        let existing = [
            makeEvent(id: "1", date: date(10)),
            makeEvent(id: "2", date: date(20))
        ]

        let incoming = [
            makeEvent(id: "3", date: date(30))
        ]

        let result = sut.execute(
            existing: existing,
            incoming: incoming
        )

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(Set(result.map(\.id)), Set(["1", "2", "3"]))
    }

    func testExecuteRemovesDuplicateEvents() {
        let existing = [
            makeEvent(id: "1", date: date(10))
        ]

        let incoming = [
            makeEvent(id: "1", date: date(20))
        ]

        let result = sut.execute(
            existing: existing,
            incoming: incoming
        )

        XCTAssertEqual(result.count, 1)
    }

    func testExecuteIncomingEventOverridesExistingEvent() {
        let existing = [
            makeEvent(id: "1", type: "PushEvent", date: date(10))
        ]

        let incoming = [
            makeEvent(id: "1", type: "WatchEvent", date: date(20))
        ]

        let result = sut.execute(
            existing: existing,
            incoming: incoming
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.type, "WatchEvent")
        XCTAssertEqual(result.first?.createdAt, date(20))
    }

    func testExecuteSortsEventsByDateDescending() {
        let events = [
            makeEvent(id: "1", date: date(10)),
            makeEvent(id: "2", date: date(30)),
            makeEvent(id: "3", date: date(20))
        ]

        let result = sut.execute(
            existing: [],
            incoming: events
        )

        XCTAssertEqual(result.map(\.id), ["2", "3", "1"])
    }

    func testExecuteReturnsEmptyArrayWhenInputsAreEmpty() {
        let result = sut.execute(existing: [], incoming: [])

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Helpers

    private func makeEvent(
        id: String,
        type: String = "PushEvent",
        date: Date
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
            createdAt: date
        )
    }

    private func date(_ seconds: TimeInterval) -> Date {
        Date(timeIntervalSince1970: seconds)
    }
}
