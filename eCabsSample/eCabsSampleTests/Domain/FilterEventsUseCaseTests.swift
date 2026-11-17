//
//  FilterEventsUseCaseTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//



import XCTest
@testable import eCabsSample

final class FilterEventsUseCaseTests: XCTestCase {

    private let sut = FilterEventsUseCase()

    private let events = [
        makeEvent(id: "1", type: "PushEvent"),
        makeEvent(id: "2", type: "IssuesEvent"),
        makeEvent(id: "3", type: "WatchEvent"),
        makeEvent(id: "4", type: "PushEvent")
    ]

    func testExecuteReturnsAllEventsWhenNoFiltersAreSelected() {
        let result = sut.execute(
            events: events,
            selectedTypes: []
        )

        XCTAssertEqual(result.map(\.id), ["1", "2", "3", "4"])
    }

    func testExecuteFiltersEventsBySingleType() {
        let result = sut.execute(
            events: events,
            selectedTypes: ["PushEvent"]
        )

        XCTAssertEqual(result.map(\.id), ["1", "4"])
        XCTAssertTrue(result.allSatisfy { $0.type == "PushEvent" })
    }

    func testExecuteFiltersEventsByMultipleTypes() {
        let result = sut.execute(
            events: events,
            selectedTypes: ["PushEvent", "IssuesEvent"]
        )

        XCTAssertEqual(result.map(\.id), ["1", "2", "4"])
    }

    func testExecuteReturnsEmptyArrayWhenNoEventsMatch() {
        let result = sut.execute(
            events: events,
            selectedTypes: ["ForkEvent"]
        )

        XCTAssertTrue(result.isEmpty)
    }

    func testExecuteReturnsEmptyArrayWhenInputIsEmpty() {
        let result = sut.execute(
            events: [],
            selectedTypes: ["PushEvent"]
        )

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Helpers

    private static func makeEvent(
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
