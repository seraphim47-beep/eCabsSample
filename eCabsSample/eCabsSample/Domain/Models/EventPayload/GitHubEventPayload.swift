//
//  GitHubEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

// **EN:** Defines the supported GitHub event payload types and maps each event type to its corresponding payload model. Unknown event types are preserved as generic JSON values.

// **IT:** Definisce le tipologie di payload GitHub supportate e associa ogni tipo di evento al relativo modello. Gli eventi non riconosciuti vengono conservati come valori JSON generici.

//
//  GitHubEventPayload.swift
//  eCabsSample
//
//  EN: Defines the supported GitHub event payload types.
//  Unknown or malformed payloads are preserved as generic JSON values.
//
//  IT: Definisce le tipologie di payload GitHub supportate.
//  I payload sconosciuti o non validi vengono conservati come valori JSON generici.
//

import Foundation

nonisolated enum GitHubEventPayload: Sendable {

    case push(PushEventPayload)
    case pullRequest(PullRequestEventPayload)
    case issues(IssuesEventPayload)
    case watch(WatchEventPayload)
    case fork(ForkEventPayload)
    case commitComment(CommitCommentEventPayload)
    case create(CreateEventPayload)
    case delete(DeleteEventPayload)
    case discussion(DiscussionEventPayload)
    case gollum(GollumEventPayload)
    case issueComment(IssueCommentEventPayload)
    case member(MemberEventPayload)
    case publicEvent(PublicEventPayload)
    case pullRequestReview(PullRequestReviewEventPayload)
    case pullRequestReviewComment(PullRequestReviewCommentEventPayload)
    case release(ReleaseEventPayload)
    case unknown(JSONValue)

    nonisolated static func decode(type: String, payload: JSONValue) throws -> GitHubEventPayload {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(payload)

        do {
            switch type {
            case "PushEvent":
                return .push(try decoder.decode(PushEventPayload.self, from: data))
            case "PullRequestEvent":
                return .pullRequest(try decoder.decode(PullRequestEventPayload.self, from: data))
            case "IssuesEvent":
                return .issues(try decoder.decode(IssuesEventPayload.self, from: data))
            case "WatchEvent":
                return .watch(try decoder.decode(WatchEventPayload.self, from: data))
            case "ForkEvent":
                return .fork(try decoder.decode(ForkEventPayload.self, from: data))
            case "CommitCommentEvent":
                return .commitComment(try decoder.decode(CommitCommentEventPayload.self, from: data))
            case "CreateEvent":
                return .create(try decoder.decode(CreateEventPayload.self, from: data))
            case "DeleteEvent":
                return .delete(try decoder.decode(DeleteEventPayload.self, from: data))
            case "DiscussionEvent":
                return .discussion(try decoder.decode(DiscussionEventPayload.self, from: data))
            case "GollumEvent":
                return .gollum(try decoder.decode(GollumEventPayload.self, from: data))
            case "IssueCommentEvent":
                return .issueComment(try decoder.decode(IssueCommentEventPayload.self, from: data))
            case "MemberEvent":
                return .member(try decoder.decode(MemberEventPayload.self, from: data))
            case "PublicEvent":
                return .publicEvent(try decoder.decode(PublicEventPayload.self, from: data))
            case "PullRequestReviewEvent":
                return .pullRequestReview(try decoder.decode(PullRequestReviewEventPayload.self, from: data))
            case "PullRequestReviewCommentEvent":
                return .pullRequestReviewComment(try decoder.decode(PullRequestReviewCommentEventPayload.self, from: data))
            case "ReleaseEvent":
                return .release(try decoder.decode(ReleaseEventPayload.self, from: data))
            default:
                return .unknown(payload)
            }
        } catch {
            return .unknown(payload)
        }
    }
}
