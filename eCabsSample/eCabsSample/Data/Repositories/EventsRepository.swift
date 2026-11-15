//
//  EventsRepository.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//  **EN:** Implements the events repository. It coordinates API requests, maps DTOs into domain models, maintains an in-memory event cache, handles ETag-based responses, and merges incoming events while removing duplicates.

//  **IT:** Implementa il repository degli eventi. Coordina le richieste API, converte i DTO in modelli Domain, mantiene una cache degli eventi in memoria, gestisce le risposte basate su ETag e unisce gli eventi ricevuti eliminando i duplicati.

import Foundation

actor EventsRepository: EventsRepositoryProtocol {

    // MARK: - Properties

    private let apiClient: GitHubAPIClient
    private let mergeEventsUseCase: MergeEventsUseCase

    private var etag: String?
    private var cachedEvents: [GitHubEvent] = []

    // MARK: - Initialization

    init(apiClient: GitHubAPIClient, mergeEventsUseCase: MergeEventsUseCase) {
        self.apiClient = apiClient
        self.mergeEventsUseCase = mergeEventsUseCase
    }

    // MARK: - Fetch Events

    func fetchEvents() async throws -> EventsFetchResult {
        let response = try await apiClient.fetchEvents(etag: etag)

        let wasModified: Bool

        switch response.result {
        case .success(let dtos):
            let incomingEvents = try dtos.map { try $0.toDomain() }

            cachedEvents = mergeEventsUseCase.execute(
                existing: cachedEvents,
                incoming: incomingEvents
            )

            wasModified = true

        case .notModified:
            wasModified = false
        }

        etag = response.etag ?? etag

        return EventsFetchResult(
            events: cachedEvents,
            pollInterval: response.pollInterval,
            wasModified: wasModified
        )
    }
}

