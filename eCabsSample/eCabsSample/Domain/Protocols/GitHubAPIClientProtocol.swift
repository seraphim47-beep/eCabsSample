//
//  GitHubAPIClientProtocol.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 17/11/2026.
//



import Foundation

protocol GitHubAPIClientProtocol: Sendable {
    func fetchEvents(etag: String?) async throws -> GitHubAPIResponse
}
