//
//  DeleteEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.
//


import Foundation

nonisolated struct DeleteEventPayload: Codable, Sendable {
    let ref: String?
    let refType: String?
    let pusherType: String?

    enum CodingKeys: String, CodingKey {
        case ref
        case refType = "ref_type"
        case pusherType = "pusher_type"
    }
}
