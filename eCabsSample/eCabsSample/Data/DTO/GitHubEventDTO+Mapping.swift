//
//  GitHubEventDTO+Mapping.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

// **EN:** Converts an API event DTO into the corresponding domain model. It also parses the event creation date and decodes the appropriate event payload.

// **IT:** Converte un DTO ricevuto dalle API nel corrispondente modello del Domain. Si occupa inoltre di convertire la data di creazione e decodificare il payload specifico dell'evento.

import Foundation

extension GitHubEventDTO {

    nonisolated func toDomain() throws -> GitHubEvent {
        guard let date = Self.parseDate(createdAt) else {
            throw MappingError.invalidDate(createdAt)
        }

        let eventPayload = try GitHubEventPayload.decode(
            type: type,
            payload: payload
        )

        return GitHubEvent(
            id: id,
            type: type,
            actor: GitHubEvent.Actor(
                id: actor.id,
                login: actor.login,
                displayLogin: actor.displayLogin,
                avatarURL: actor.avatarURL
            ),
            repository: GitHubEvent.Repository(
                id: repo.id,
                name: repo.name,
                url: repo.url
            ),
            payload: eventPayload,
            isPublic: isPublic,
            createdAt: date
        )
    }

    private nonisolated static func parseDate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = formatter.date(from: value) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
}

enum MappingError: Error {
    case invalidDate(String)
}
