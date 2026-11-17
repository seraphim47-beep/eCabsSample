//
//  PullRequestReviewCommentEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.

import Foundation

nonisolated struct PullRequestReviewCommentEventPayload: Codable, Sendable {
    let action: String?
    let pullRequest: JSONValue?
    let comment: JSONValue?

    enum CodingKeys: String, CodingKey {
        case action
        case pullRequest = "pull_request"
        case comment
    }
}
