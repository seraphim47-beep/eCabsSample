//
//  GitHubEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

// **EN:** Defines the supported GitHub event payload types and maps each event type to its corresponding payload model. Unknown event types are preserved as generic JSON values.

// **IT:** Definisce le tipologie di payload GitHub supportate e associa ogni tipo di evento al relativo modello. Gli eventi non riconosciuti vengono conservati come valori JSON generici.

import Foundation

enum GitHubEventPayload: Sendable {

    case push(PushEventPayload)
    case pullRequest(PullRequestEventPayload)
    case issues(IssuesEventPayload)
    case watch(WatchEventPayload)
    case fork(ForkEventPayload)

    case unknown(JSONValue)

    nonisolated static func decode(
        type: String,
        payload: JSONValue
    ) throws -> GitHubEventPayload {

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(payload)

        switch type {

        case "PushEvent":
            return .push(
                try decoder.decode(PushEventPayload.self, from: data)
            )

        case "PullRequestEvent":
            return .pullRequest(
                try decoder.decode(PullRequestEventPayload.self, from: data)
            )

        case "IssuesEvent":
            return .issues(
                try decoder.decode(IssuesEventPayload.self, from: data)
            )

        case "WatchEvent":
            return .watch(
                try decoder.decode(WatchEventPayload.self, from: data)
            )

        case "ForkEvent":
            return .fork(
                try decoder.decode(ForkEventPayload.self, from: data)
            )

        default:
            return .unknown(payload)
        }
    }
}
