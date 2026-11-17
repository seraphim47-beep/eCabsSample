//
//  ReleaseEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.

import Foundation

nonisolated struct ReleaseEventPayload: Codable, Sendable {
    let action: String?
    let release: JSONValue?
}
