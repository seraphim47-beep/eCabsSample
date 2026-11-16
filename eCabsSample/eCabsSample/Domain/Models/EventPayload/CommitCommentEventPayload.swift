//
//  CommitCommentEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.
//


import Foundation

nonisolated struct CommitCommentEventPayload: Codable, Sendable {
    let action: String?
    let comment: JSONValue?
    let commitID: String?

    enum CodingKeys: String, CodingKey {
        case action
        case comment
        case commitID = "commit_id"
    }
}
