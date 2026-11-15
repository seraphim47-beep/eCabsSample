//
//  GitHubAPIResponse.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

//  **EN:** Defines the response structure returned by the API client. It distinguishes between a successful response containing events and a `304 Not Modified` response, while also carrying the ETag and polling interval.

//**IT:** Definisce la struttura della risposta restituita dal client API. Distingue tra una risposta contenente nuovi eventi e una risposta `304 Not Modified`, mantenendo anche l'ETag e l'intervallo di polling.


import Foundation

struct GitHubAPIResponse: Sendable {

    enum Result: Sendable {
        case success([GitHubEventDTO])
        case notModified
    }

    let result: Result
    let etag: String?
    let pollInterval: Int
}
