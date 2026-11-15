//
//  EventDetailViewModel.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Prepara i dati necessari alla visualizzazione del dettaglio.
//


import Foundation

@MainActor
final class EventDetailViewModel {

    let event: GitHubEvent

    init(event: GitHubEvent) {
        self.event = event
    }
}
