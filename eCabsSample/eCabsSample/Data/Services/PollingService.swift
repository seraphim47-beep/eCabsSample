//
//  PollingService 2.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//

import Foundation

@MainActor
final class PollingService {

    // MARK: - Properties

    private var pollingTask: Task<Void, Never>?

    // MARK: - Lifecycle

    func start(interval: Int, operation: @escaping @MainActor () async -> Int?) {
        stop()

        pollingTask = Task { @MainActor in
            var currentInterval = max(interval, 1)

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(currentInterval))
                } catch {
                    break
                }

                guard !Task.isCancelled else {
                    break
                }

                if let nextInterval = await operation() {
                    currentInterval = max(nextInterval, 1)
                }
            }
        }
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}
