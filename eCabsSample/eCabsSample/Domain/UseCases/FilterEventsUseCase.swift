//
//  FilterEventsUseCase.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

//  **EN:** Filters GitHub events based on the selected event types. If no filters are selected, all events are returned.

//  **IT:** Filtra gli eventi GitHub in base alle tipologie selezionate. Se non viene selezionato alcun filtro, vengono restituiti tutti gli eventi.

import Foundation

nonisolated struct FilterEventsUseCase: Sendable {

    nonisolated func execute(
        events: [GitHubEvent],
        selectedTypes: Set<String>
    ) -> [GitHubEvent] {

        guard !selectedTypes.isEmpty else {
            return events
        }

        return events.filter {
            selectedTypes.contains($0.type)
        }
    }
}
