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

    private(set) var events: [GitHubEvent] = []

    init() {}
}
