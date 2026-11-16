//
//  PushEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//  **EN:** Represents the payload of a GitHub `PushEvent`, including the branch reference, push ID, head commit, and previous commit.

//  **IT:** Rappresenta il payload di un evento GitHub `PushEvent`, includendo il riferimento al branch, l'ID del push, il commit corrente e quello precedente.

import Foundation

nonisolated struct PushEventPayload: Decodable, Sendable {

    let repositoryID: Int?
    let pushID: Int?
    let ref: String?
    let head: String?
    let before: String?

    enum CodingKeys: String, CodingKey {
        case repositoryID = "repository_id"
        case pushID = "push_id"
        case ref
        case head
        case before
    }
}
