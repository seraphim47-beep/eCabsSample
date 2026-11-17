//
//  PollingService 2.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

//  **EN:** Manages periodic refreshes. It is isolated to `MainActor`, maintains a cancellable task, and waits for the configured interval before invoking the operation. If the operation returns a new interval, that value is used for the next cycle. The minimum interval is one second.

//  **IT:** Gestisce il ciclo di aggiornamento periodico. È isolato su `MainActor`, mantiene un task cancellabile e attende l'intervallo prima di invocare l'operazione. Se l'operazione restituisce un nuovo intervallo, questo viene applicato al ciclo successivo. L'intervallo minimo è un secondo.

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
