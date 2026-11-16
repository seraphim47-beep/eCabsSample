//
//  PublicEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.
//


import Foundation

nonisolated struct PublicEventPayload: Codable, Sendable {
    let repository: JSONValue?
}
