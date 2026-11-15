//
//  GitHubRepositoryDTO.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

// **EN:** Represents the repository associated with an event, including its ID, name, and API URL.

// **IT:** Rappresenta il repository associato a un evento, includendo ID, nome e URL delle API GitHub.


import Foundation

struct GitHubRepositoryDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let url: URL
}
