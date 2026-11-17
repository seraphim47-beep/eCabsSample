//
//  GitHubAPIClient.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

//  **EN:** Handles HTTP communication with the GitHub REST API. It fetches public events, configures request headers, supports ETag-based conditional requests, reads the server polling interval, and handles HTTP errors and rate limits.

//  **IT:** Gestisce la comunicazione HTTP con le API REST di GitHub. Recupera gli eventi pubblici, configura gli header delle richieste, supporta le richieste condizionali tramite ETag, legge l'intervallo di polling indicato dal server e gestisce gli errori HTTP e i limiti di richieste.

import Foundation

struct GitHubAPIClient: Sendable {

    // MARK: - Properties

    private let session: URLSession
    private let tokenStore: GitHubTokenStore

    private let defaultPollInterval = 60

    // MARK: - Initialization

    init(session: URLSession = .shared, tokenStore: GitHubTokenStore = GitHubTokenStore()) {
        self.session = session
        self.tokenStore = tokenStore
    }

    // MARK: - Fetch Events

    func fetchEvents(etag: String?) async throws -> GitHubAPIResponse {
        guard let url = URL(string: "https://api.github.com/events") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2026-03-10", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("GitHubEvents-iOS", forHTTPHeaderField: "User-Agent")
        
        if let token = try await tokenStore.read(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            if error is CancellationError {
                throw error
            }

            throw APIError.networkError
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        let responseETag = httpResponse.value(forHTTPHeaderField: "ETag")

        // Get response pollInterval
        let pollInterval = validatedPollInterval(
            httpResponse.value(forHTTPHeaderField: "X-Poll-Interval")
        )

        switch httpResponse.statusCode {

        case 200:
            do {
                let events = try JSONDecoder().decode(
                    [GitHubEventDTO].self,
                    from: data
                )

                return GitHubAPIResponse(
                    result: .success(events),
                    etag: responseETag ?? etag,
                    pollInterval: pollInterval
                )
            } catch {
                throw APIError.decodingError
            }

        case 304:
            return GitHubAPIResponse(
                result: .notModified,
                etag: responseETag ?? etag,
                pollInterval: pollInterval
            )

        case 403, 429:
            throw rateLimitError(from: httpResponse)

        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - Poll Interval

    private func validatedPollInterval(_ value: String?) -> Int {
        guard let value,
              let interval = Int(value),
              interval > 0 else {
            return defaultPollInterval
        }

        return interval
    }

    // MARK: - Rate Limit

    private func rateLimitError(from response: HTTPURLResponse) -> APIError {
        let remaining = response.value(forHTTPHeaderField: "X-RateLimit-Remaining")

        let resetTimestamp = response.value(forHTTPHeaderField: "X-RateLimit-Reset").flatMap(TimeInterval.init)

        let retryAfter = response.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)

        if let retryAfter {
            return .rateLimited(
                resetDate: Date().addingTimeInterval(retryAfter)
            )
        }

        if remaining == "0",
           let resetTimestamp {
            return .rateLimited(
                resetDate: Date(timeIntervalSince1970: resetTimestamp)
            )
        }

        if response.statusCode == 429 || remaining == "0" {
            return .rateLimited(
                resetDate: Date().addingTimeInterval(60)
            )
        }

        return .httpError(response.statusCode)
    }
}
