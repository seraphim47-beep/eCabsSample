//
//  EventDetailViewModelTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//

import XCTest
@testable import eCabsSample

final class EventDetailViewModelTests: XCTestCase {

    /// Validates mapping of the event's general properties.
    func testInitializationMapsEventProperties() {
        let event = makeEvent(payload: .watch(WatchEventPayload(action: "started")))
        let sut = EventDetailViewModel(event: event)

        XCTAssertEqual(sut.actorName, "test-user")
        XCTAssertEqual(sut.actorAvatarURL, URL(string: "https://example.com/avatar.png"))
        XCTAssertEqual(sut.eventType, "Watch")
        XCTAssertEqual(sut.repositoryName, "test/repository")
        XCTAssertEqual(sut.repositoryURL, URL(string: "https://github.com/test/repository"))
        XCTAssertFalse(sut.eventDate.isEmpty)
        XCTAssertFalse(sut.isPublic.isEmpty)
    }

    /// Validates extraction of a Watch Event action.
    func testWatchEventMapsAction() {
        let event = makeEvent(payload: .watch(WatchEventPayload(action: "started")))
        let sut = EventDetailViewModel(event: event)

        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(sut.sections.first?.items.count, 1)
        XCTAssertEqual(sut.sections.first?.items.first?.value, "started")
    }

    ///  Validates extraction of the branch, Push ID, and commit identifiers.
    func testPushEventMapsBranchAndCommitInformation() {
        let payload = PushEventPayload(
            repositoryID: 123,
            pushID: 456,
            ref: "refs/heads/main",
            head: "abc123",
            before: "def456"
        )
        let event = makeEvent(payload: .push(payload))
        let sut = EventDetailViewModel(event: event)

        let values = sut.sections.flatMap(\.items).map(\.value)

        XCTAssertTrue(values.contains("main"))
        XCTAssertTrue(values.contains("456"))
        XCTAssertTrue(values.contains("abc123"))
        XCTAssertTrue(values.contains("def456"))
    }

    ///  Validates mapping of available fields from an unknown payload.
    func testUnknownPayloadMapsAvailableValues() {
        let payload = JSONValue.object([
            "action": .string("created"),
            "name": .string("test-name"),
            "count": .integer(10)
        ])
        let event = makeEvent(payload: .unknown(payload))
        let sut = EventDetailViewModel(event: event)

        let values = sut.sections.flatMap(\.items).map(\.value)

        XCTAssertTrue(values.contains("created"))
        XCTAssertTrue(values.contains("test-name"))
        XCTAssertTrue(values.contains("10"))
    }

    /// Ensures an empty unknown payload does not   generate sections.
    func testEmptyPayloadReturnsNoSections() {
        let event = makeEvent(payload: .unknown(.object([:])))
        let sut = EventDetailViewModel(event: event)

        XCTAssertTrue(sut.sections.isEmpty)
    }

    // MARK: - Helpers

    private func makeEvent(payload: GitHubEventPayload) -> GitHubEvent {
        GitHubEvent(
            id: UUID().uuidString,
            type: "WatchEvent",
            actor: GitHubEvent.Actor(
                id: 1,
                login: "test-user",
                displayLogin: "test-user",
                avatarURL: URL(string: "https://example.com/avatar.png")
            ),
            repository: GitHubEvent.Repository(
                id: 123,
                name: "test/repository",
                url: URL(string: "https://github.com/test/repository")!
            ),
            payload: payload,
            isPublic: true,
            createdAt: Date()
        )
    }
}
