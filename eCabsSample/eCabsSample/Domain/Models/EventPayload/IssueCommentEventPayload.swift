//
//  IssueCommentEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.

import Foundation

nonisolated struct IssueCommentEventPayload: Codable, Sendable {
    let action: String?
    let issue: JSONValue?
    let comment: JSONValue?
}
