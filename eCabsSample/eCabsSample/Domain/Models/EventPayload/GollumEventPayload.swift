//
//  GollumEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.

import Foundation

nonisolated struct GollumEventPayload: Codable, Sendable {
    let pages: [JSONValue]?
}
