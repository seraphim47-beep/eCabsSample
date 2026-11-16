//
//  WatchEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//  **EN:** Represents the payload of a `WatchEvent`, including the action performed by the user.

//  **IT:** Rappresenta il payload di un evento `WatchEvent`, includendo l'azione eseguita dall'utente.

import Foundation

nonisolated struct WatchEventPayload: Decodable, Sendable {

    let action: String
}
