//
//  MemberEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.

import Foundation

nonisolated struct MemberEventPayload: Codable, Sendable {
    let action: String?
    let member: JSONValue?
}
