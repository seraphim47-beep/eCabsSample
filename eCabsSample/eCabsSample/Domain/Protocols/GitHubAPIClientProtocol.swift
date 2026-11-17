//
//  GitHubAPIClientProtocol.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.

//  **EN:** Defines the asynchronous API client contract, including conditional requests using an ETag. It allows the repository to depend on an abstraction rather than a concrete implementation.

//  **IT:** Definisce il contratto asincrono del client API, inclusa la richiesta condizionale con ETag. Consente al repository di dipendere da un'astrazione anziché dall'implementazione concreta.

import Foundation

protocol GitHubAPIClientProtocol: Sendable {
    func fetchEvents(etag: String?) async throws -> GitHubAPIResponse
}
