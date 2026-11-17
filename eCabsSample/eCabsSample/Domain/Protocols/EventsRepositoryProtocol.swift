//
//  EventsRepositoryProtocol.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

//  **EN:** Defines the contract for retrieving GitHub events, separating the domain layer from the concrete data implementation.

//  **IT:** Definisce il contratto per il recupero degli eventi GitHub, separando il Domain dall'implementazione concreta del livello Data.

import Foundation

struct EventsFetchResult: Sendable {
    let events: [GitHubEvent]
    let pollInterval: Int
    let wasModified: Bool
}

protocol EventsRepositoryProtocol: Sendable {
    func fetchEvents() async throws -> EventsFetchResult
}
