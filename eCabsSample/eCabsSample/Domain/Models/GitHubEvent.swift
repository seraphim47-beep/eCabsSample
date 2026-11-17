//
//  GitHubEvent.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Modello principale di un evento GitHub.

// **EN:** The application's main event model. It represents the event identifier, type, actor, repository, payload, visibility, and creation date.

// **IT:** È il modello principale dell'applicazione. Rappresenta identificativo, tipologia, autore, repository, payload, visibilità e data di creazione dell'evento.

import Foundation

struct GitHubEvent: Identifiable, Sendable {

    let id: String
    let type: String

    let actor: Actor
    let repository: Repository

    let payload: GitHubEventPayload

    let isPublic: Bool
    let createdAt: Date

    struct Actor: Sendable {
        let id: Int
        let login: String
        let displayLogin: String?
        let avatarURL: URL?
    }

    struct Repository: Sendable {
        let id: Int
        let name: String
        let url: URL
    }
}
