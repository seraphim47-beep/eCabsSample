//
//  MergeEventsUseCase.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

//  **EN:** Merges existing and incoming GitHub events, removes duplicates using the event ID as a unique identifier, and sorts the resulting collection by creation date in descending order.

//  **IT:** Unisce gli eventi GitHub esistenti con quelli appena ricevuti, elimina i duplicati utilizzando l'ID dell'evento come identificatore univoco e ordina il risultato per data di creazione decrescente.

import Foundation

struct MergeEventsUseCase: Sendable {

    nonisolated func execute(
        existing: [GitHubEvent],
        incoming: [GitHubEvent]
    ) -> [GitHubEvent] {

        var eventsByID: [String: GitHubEvent] = [:]

        for event in existing {
            eventsByID[event.id] = event
        }

        for event in incoming {
            eventsByID[event.id] = event
        }

        return eventsByID.values.sorted {
            $0.createdAt > $1.createdAt
        }
    }
}
