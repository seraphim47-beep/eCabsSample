//
//  PullRequestEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//  **EN:** Represents the payload of a `PullRequestEvent`, including its action, number, and pull request data.

//  **IT:** Rappresenta il payload di un evento `PullRequestEvent`, includendo l'azione eseguita, il numero e i dati della Pull Request.

import Foundation

struct PullRequestEventPayload: Decodable, Sendable {

    let action: String
    let number: Int
    let pullRequest: JSONValue

    enum CodingKeys: String, CodingKey {
        case action
        case number
        case pullRequest = "pull_request"
    }
}
