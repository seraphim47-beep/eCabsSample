//
//  CreateEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.
//


import Foundation

nonisolated struct CreateEventPayload: Codable, Sendable {
    let ref: String?
    let refType: String?
    let masterBranch: String?
    let description: String?
    let pusherType: String?

    enum CodingKeys: String, CodingKey {
        case ref
        case refType = "ref_type"
        case masterBranch = "master_branch"
        case description
        case pusherType = "pusher_type"
    }
}
