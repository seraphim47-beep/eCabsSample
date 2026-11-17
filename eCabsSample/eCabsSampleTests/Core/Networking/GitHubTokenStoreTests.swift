//
//  GitHubTokenStoreTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//



import XCTest
@testable import eCabsSample

final class GitHubTokenStoreTests: XCTestCase {

    private func makeStore() -> GitHubTokenStore {
        GitHubTokenStore(
            service: "GitHubEventsTests.\(UUID().uuidString)",
            account: "test-token"
        )
    }

    func testReadReturnsNilWhenTokenDoesNotExist() async throws {
        let store = makeStore()

        let token = try await store.read()

        XCTAssertNil(token)
    }

    func testSaveAndReadToken() async throws {
        let store = makeStore()
        let expectedToken = "ghp_test_token_123456"

        try await store.save(expectedToken)
        let actualToken = try await store.read()

        XCTAssertEqual(actualToken, expectedToken)

        try await store.delete()
    }

    func testSaveUpdatesExistingToken() async throws {
        let store = makeStore()

        try await store.save("old_token")
        try await store.save("new_token")

        let actualToken = try await store.read()

        XCTAssertEqual(actualToken, "new_token")

        try await store.delete()
    }

    func testDeleteRemovesToken() async throws {
        let store = makeStore()

        try await store.save("token_to_delete")
        try await store.delete()

        let actualToken = try await store.read()

        XCTAssertNil(actualToken)
    }

    func testDeleteDoesNotThrowWhenTokenDoesNotExist() async throws {
        let store = makeStore()

        try await store.delete()
        try await store.delete()

        let actualToken = try await store.read()

        XCTAssertNil(actualToken)
    }
}
