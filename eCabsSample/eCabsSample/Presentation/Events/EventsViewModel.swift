//
//  EventsViewModel.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Gestisce lo stato della lista, il caricamento, il filtraggio e l'aggiornamento.
//

import Foundation

@MainActor
final class EventsViewModel {

    // MARK: - Properties

    private let repository: EventsRepositoryProtocol
    private let filterEventsUseCase: FilterEventsUseCase
    private let pollingService: PollingService

    private var allEvents: [GitHubEvent] = []
    private var hasLoadedEvents = false

    private(set) var currentPollInterval = 60
    private(set) var events: [GitHubEvent] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var selectedTypes: Set<String> = []
    private(set) var lastUpdatedAt: Date?
    private(set) var availableEventTypes: [String] = []
    var onStateChange: (() -> Void)?
    
    private let preferredEventTypeOrder = [
        "PushEvent",
        "PullRequestEvent",
        "IssuesEvent",
        "WatchEvent",
        "ForkEvent"
    ]

    // MARK: - Initialization

    init(repository: EventsRepositoryProtocol, filterEventsUseCase: FilterEventsUseCase = FilterEventsUseCase()) {
        self.repository = repository
        self.filterEventsUseCase = filterEventsUseCase
        self.pollingService = PollingService()
    }

    // MARK: - Data Loading

    func loadEvents() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        onStateChange?()

        do {
            let result = try await repository.fetchEvents()

            allEvents = result.events
            currentPollInterval = result.pollInterval
            if result.wasModified {
                lastUpdatedAt = Date()
            }
            hasLoadedEvents = true

            applyFilters()

            isLoading = false
            onStateChange?()

            startPolling()

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            onStateChange?()
        }
    }

    // MARK: - Automatic Refresh

    private func startPolling() {
        pollingService.start(interval: currentPollInterval) { [weak self] in
            await self?.refreshEvents()
        }
    }

    private func refreshEvents() async -> Int? {
        do {
            let result = try await repository.fetchEvents()

            allEvents = result.events
            currentPollInterval = result.pollInterval
            if result.wasModified {
                lastUpdatedAt = Date()
            }
            errorMessage = nil

            applyFilters()
            onStateChange?()

            return result.pollInterval

        } catch let error as APIError {
            errorMessage = error.localizedDescription
            onStateChange?()

            if case .rateLimited(let resetDate) = error,
               let resetDate {
                let delay = max(1, Int(ceil(resetDate.timeIntervalSinceNow)))
                currentPollInterval = delay
                return delay
            }

            return currentPollInterval

        } catch {
            errorMessage = error.localizedDescription
            onStateChange?()

            return currentPollInterval
        }
    }

    // MARK: - Polling Control

    func resumePolling() {
        guard hasLoadedEvents else {
            return
        }

        startPolling()
    }

    func stopPolling() {
        pollingService.stop()
    }

    // MARK: - Filtering

    func updateFilters(_ selectedTypes: Set<String>) {
        self.selectedTypes = selectedTypes
        applyFilters()
        onStateChange?()
    }

    private func applyFilters() {
        let availableTypes = Set(allEvents.map(\.type))

        var types = preferredEventTypeOrder.filter {
            availableTypes.contains($0)
        }

        let additionalTypes = availableTypes
            .subtracting(Set(preferredEventTypeOrder))
            .sorted()

        let totalTypes = types.count + additionalTypes.count

        if totalTypes < 5 {
            let missingTypes = preferredEventTypeOrder.filter {
                !availableTypes.contains($0)
            }

            types.append(contentsOf: missingTypes.prefix(5 - totalTypes))
        }

        types.append(contentsOf: additionalTypes)

        availableEventTypes = types

        events = filterEventsUseCase.execute(
            events: allEvents,
            selectedTypes: selectedTypes
        )
    }
    
//    private func applyFilters() {
//        let availableTypes = Set(allEvents.map(\.type))
//
//        availableEventTypes = preferredEventTypeOrder.filter {
//            availableTypes.contains($0)
//        }
//
//        let additionalTypes = availableTypes
//            .subtracting(preferredEventTypeOrder)
//            .sorted()
//
//        availableEventTypes.append(contentsOf: additionalTypes)
//
//        events = filterEventsUseCase.execute(
//            events: allEvents,
//            selectedTypes: selectedTypes
//        )
//    }
}
