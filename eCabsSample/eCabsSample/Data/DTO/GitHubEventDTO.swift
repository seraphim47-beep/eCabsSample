//
//  GitHubEventDTO.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

// **EN:** Represents the raw event data received from the GitHub API, including the event ID, type, actor, repository, payload, visibility, and creation date.

// **IT:** Rappresenta i dati grezzi di un evento ricevuto dalle API GitHub, inclusi ID, tipologia, autore, repository, payload, visibilità e data di creazione.

import Foundation

struct GitHubEventDTO: Decodable, Sendable {
    let id: String
    let type: String
    let actor: GitHubActorDTO
    let repo: GitHubRepositoryDTO
    let payload: JSONValue
    let isPublic: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case actor
        case repo
        case payload
        case isPublic = "public"
        case createdAt = "created_at"
    }
}
