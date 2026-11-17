//
//  DiscussionEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.

import Foundation

nonisolated struct DiscussionEventPayload: Codable, Sendable {
    let action: String?
    let discussion: JSONValue?
    let changes: JSONValue?
}
