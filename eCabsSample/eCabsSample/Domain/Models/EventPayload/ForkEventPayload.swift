//
//  ForkEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//  **EN:** Represents the payload of a `ForkEvent`, including information about the newly created repository.

//  **IT:** Rappresenta il payload di un evento `ForkEvent`, includendo le informazioni sul nuovo repository creato.

import Foundation

struct ForkEventPayload: Decodable, Sendable {

    let action: String?
    let forkee: JSONValue
}
