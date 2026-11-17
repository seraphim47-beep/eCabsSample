//
//  PollingServiceTests.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//



import XCTest
@testable import eCabsSample

@MainActor
final class PollingServiceTests: XCTestCase {

    func testPollingExecutesOperationAfterInitialInterval() async {
        let sut = PollingService()
        var executionCount = 0

        sut.start(interval: 1) {
            executionCount += 1
            return nil
        }

        try? await Task.sleep(for: .milliseconds(1200))
        sut.stop()

        XCTAssertEqual(executionCount, 1)
    }

    func testPollingStopsExecutingAfterStop() async {
        let sut = PollingService()
        var executionCount = 0

        sut.start(interval: 1) {
            executionCount += 1
            return nil
        }

        try? await Task.sleep(for: .milliseconds(1200))
        sut.stop()

        let countAfterStop = executionCount

        try? await Task.sleep(for: .milliseconds(1200))

        XCTAssertEqual(executionCount, countAfterStop)
        XCTAssertEqual(executionCount, 1)
    }

    func testPollingUsesUpdatedInterval() async {
        let sut = PollingService()
        var executionCount = 0

        sut.start(interval: 1) {
            executionCount += 1
            return 2
        }

        // Attende la prima esecuzione.
        try? await Task.sleep(for: .milliseconds(1200))
        XCTAssertEqual(executionCount, 1)

        // Il nuovo intervallo è di 2 secondi.
        try? await Task.sleep(for: .milliseconds(1100))
        XCTAssertEqual(executionCount, 1)

        try? await Task.sleep(for: .milliseconds(1100))
        XCTAssertEqual(executionCount, 2)

        sut.stop()
    }

    func testPollingUsesMinimumIntervalOfOneSecond() async {
        let sut = PollingService()
        var executionCount = 0

        sut.start(interval: 0) {
            executionCount += 1
            return nil
        }

        try? await Task.sleep(for: .milliseconds(1200))
        sut.stop()

        XCTAssertEqual(executionCount, 1)
    }

    func testStartingPollingAgainStopsPreviousPolling() async {
        let sut = PollingService()
        var firstCount = 0
        var secondCount = 0

        sut.start(interval: 1) {
            firstCount += 1
            return nil
        }

        sut.start(interval: 1) {
            secondCount += 1
            return nil
        }

        try? await Task.sleep(for: .milliseconds(1200))
        sut.stop()

        XCTAssertEqual(firstCount, 0)
        XCTAssertEqual(secondCount, 1)
    }
}
