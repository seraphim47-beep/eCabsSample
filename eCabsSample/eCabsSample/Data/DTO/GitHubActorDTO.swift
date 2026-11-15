//
//  GitHubActorDTO.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

// **EN:** Represents the GitHub user or actor associated with an event, including their ID, username, display login, and avatar URL.

// **IT:** Rappresenta l'utente GitHub associato a un evento, includendo ID, username, nome visualizzato e URL dell'immagine del profilo.


import Foundation

struct GitHubActorDTO: Decodable, Sendable {
    let id: Int
    let login: String
    let displayLogin: String?
    let avatarURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case displayLogin = "display_login"
        case avatarURL = "avatar_url"
    }
}
