//
//  APIError.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

// **EN:** Defines the network and API errors that can occur when communicating with GitHub. It also provides localized error descriptions to make failures easier to display and understand.

// **IT:** Definisce gli errori di rete e gli errori API che possono verificarsi durante la comunicazione con GitHub. Fornisce inoltre descrizioni leggibili degli errori, utili per mostrarli e interpretarli nell'interfaccia.

import Foundation

enum APIError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case rateLimited(resetDate: Date?)
    case decodingError
    case networkError
}
