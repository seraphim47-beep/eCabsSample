//
//  PullRequestReviewEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.

import Foundation

nonisolated struct PullRequestReviewEventPayload: Codable, Sendable {
    let action: String?
    let pullRequest: JSONValue?
    let review: JSONValue?

    enum CodingKeys: String, CodingKey {
        case action
        case pullRequest = "pull_request"
        case review
    }
}
