//
//  EventDetailViewModel.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Prepara i dati necessari alla visualizzazione del dettaglio.
//


import Foundation

struct EventDetailItem: Identifiable {
    let title: String
    let value: String
    let url: URL?

    var id: String { title }
}

struct EventDetailSection: Identifiable {
    let title: String
    let items: [EventDetailItem]

    var id: String { title }
}

struct EventDetailViewModel {

    // MARK: - Properties

    let actorName: String
    let actorAvatarURL: URL?
    let eventType: String
    let eventDate: String
    let isPublic: String
    let repositoryName: String
    let repositoryURL: URL
    let sections: [EventDetailSection]

    // MARK: - Initialization

    init(event: GitHubEvent) {
        actorName = event.actor.login
        actorAvatarURL = event.actor.avatarURL
        eventType = event.type.replacingOccurrences(of: "Event", with: "")
        eventDate = event.createdAt.formatted(date: .long, time: .shortened)
        isPublic = String(localized: event.isPublic ? "event_detail.visibility.public" : "event_detail.visibility.private")
        repositoryName = event.repository.name
        repositoryURL = event.repository.url
        sections = Self.makeSections(for: event)
    }

    // MARK: - Sections

    private static func makeSections(for event: GitHubEvent) -> [EventDetailSection] {
        var items: [EventDetailItem] = []

        switch event.payload {

        case .push(let payload):
            append(payload.ref?.replacingOccurrences(of: "refs/heads/", with: ""), title: "event_detail.branch", to: &items)
            append(payload.pushID.map(String.init), title: "event_detail.push_id", to: &items)
            append(payload.head, title: "event_detail.head", to: &items)
            append(payload.before, title: "event_detail.before", to: &items)

        case .pullRequest(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(String(payload.number), title: "event_detail.number", to: &items)
            append(objectValue(payload.pullRequest, keys: ["title"]), title: "event_detail.title", to: &items)
            append(objectValue(payload.pullRequest, keys: ["state"]), title: "event_detail.state", to: &items)
            appendURL(payload.pullRequest, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .issues(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(objectValue(payload.issue, keys: ["title"]), title: "event_detail.title", to: &items)
            append(objectValue(payload.issue, keys: ["number"]).map { "#\($0)" }, title: "event_detail.number", to: &items)
            append(objectValue(payload.issue, keys: ["state"]), title: "event_detail.state", to: &items)
            append(objectValue(payload.assignee, keys: ["login"]), title: "event_detail.assignee", to: &items)

            let assignees = payload.assignees?.compactMap {
                objectValue($0, keys: ["login"])
            }.joined(separator: ", ")

            append(assignees, title: "event_detail.assignees", to: &items)

            let labels = payload.labels?.compactMap {
                objectValue($0, keys: ["name"])
            }.joined(separator: ", ")

            append(labels, title: "event_detail.labels", to: &items)

            if labels?.isEmpty != false {
                append(objectValue(payload.label, keys: ["name"]), title: "event_detail.labels", to: &items)
            }

            appendURL(payload.issue, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .watch(let payload):
            append(payload.action, title: "event_detail.action", to: &items)

        case .fork(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(objectValue(payload.forkee, keys: ["full_name", "name"]), title: "event_detail.forked_repository", to: &items)
            appendURL(payload.forkee, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .commitComment(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(payload.commitID, title: "event_detail.commit_id", to: &items)
            append(objectValue(payload.comment, keys: ["body"]), title: "event_detail.comment", to: &items)
            appendURL(payload.comment, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .create(let payload):
            append(payload.refType, title: "event_detail.ref_type", to: &items)
            append(payload.ref, title: "event_detail.ref", to: &items)
            append(payload.masterBranch, title: "event_detail.master_branch", to: &items)
            append(payload.description, title: "event_detail.description", to: &items)
            append(payload.pusherType, title: "event_detail.pusher_type", to: &items)

        case .delete(let payload):
            append(payload.refType, title: "event_detail.ref_type", to: &items)
            append(payload.ref, title: "event_detail.ref", to: &items)
            append(payload.pusherType, title: "event_detail.pusher_type", to: &items)

        case .discussion(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(objectValue(payload.discussion, keys: ["title"]), title: "event_detail.title", to: &items)
            append(objectValue(payload.discussion, keys: ["number"]).map { "#\($0)" }, title: "event_detail.number", to: &items)
            append(objectValue(payload.discussion, keys: ["category", "name"]), title: "event_detail.category", to: &items)
            append(objectValue(payload.changes, keys: ["body"]), title: "event_detail.description", to: &items)
            appendURL(payload.discussion, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .gollum(let payload):
            let pages = payload.pages?.compactMap {
                objectValue($0, keys: ["page_name", "title"])
            }.joined(separator: ", ")

            append(pages, title: "event_detail.pages", to: &items)

            if let pagesValues = payload.pages {
                for page in pagesValues {
                    appendURL(page, keys: ["html_url"], title: "event_detail.url", to: &items)
                }
            }

        case .issueComment(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(objectValue(payload.issue, keys: ["title"]), title: "event_detail.title", to: &items)
            append(objectValue(payload.issue, keys: ["number"]).map { "#\($0)" }, title: "event_detail.number", to: &items)
            append(objectValue(payload.comment, keys: ["body"]), title: "event_detail.comment", to: &items)
            appendURL(payload.comment, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .member(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(objectValue(payload.member, keys: ["login"]), title: "event_detail.member", to: &items)

        case .publicEvent(let payload):
            append(objectValue(payload.repository, keys: ["full_name", "name"]), title: "event_detail.repository", to: &items)
            appendURL(payload.repository, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .pullRequestReview(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(objectValue(payload.pullRequest, keys: ["title"]), title: "event_detail.title", to: &items)
            append(objectValue(payload.pullRequest, keys: ["number"]).map { "#\($0)" }, title: "event_detail.number", to: &items)
            append(objectValue(payload.review, keys: ["state"]), title: "event_detail.review_state", to: &items)
            append(objectValue(payload.review, keys: ["body"]), title: "event_detail.comment", to: &items)
            appendURL(payload.pullRequest, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .pullRequestReviewComment(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(objectValue(payload.pullRequest, keys: ["title"]), title: "event_detail.title", to: &items)
            append(objectValue(payload.pullRequest, keys: ["number"]).map { "#\($0)" }, title: "event_detail.number", to: &items)
            append(objectValue(payload.comment, keys: ["body"]), title: "event_detail.comment", to: &items)
            append(objectValue(payload.comment, keys: ["path"]), title: "event_detail.file", to: &items)
            appendURL(payload.comment, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .release(let payload):
            append(payload.action, title: "event_detail.action", to: &items)
            append(objectValue(payload.release, keys: ["name", "tag_name"]), title: "event_detail.release", to: &items)
            append(objectValue(payload.release, keys: ["tag_name"]), title: "event_detail.tag", to: &items)
            append(objectValue(payload.release, keys: ["body"]), title: "event_detail.description", to: &items)
            appendURL(payload.release, keys: ["html_url"], title: "event_detail.url", to: &items)

        case .unknown(let payload):
            items.append(contentsOf: unknownPayloadItems(payload))
        }

        guard !items.isEmpty else {
            return []
        }

        return [
            EventDetailSection(
                title: String(localized: "event_detail.payload"),
                items: items
            )
        ]
    }

    // MARK: - Helpers

    private static func append(_ value: String?, title: String, url: URL? = nil, to items: inout [EventDetailItem]) {
        guard let value, !value.isEmpty else { return }

        items.append(EventDetailItem(
            title: String(localized: String.LocalizationValue(title)),
            value: value,
            url: url
        ))
    }

    private static func appendURL(_ value: JSONValue?, keys: [String], title: String, to items: inout [EventDetailItem]) {
        guard let string = objectValue(value, keys: keys),
              let url = validatedURL(string) else {
            return
        }

        append(string, title: title, url: url, to: &items)
    }

    private static func validatedURL(_ string: String) -> URL? {
        guard let url = URL(string: string),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http" else {
            return nil
        }

        return url
    }

    private static func objectValue(_ value: JSONValue?, keys: [String]) -> String? {
        guard case .object(let object)? = value else { return nil }

        for key in keys {
            if let result = displayValue(object[key]) {
                return result
            }
        }

        return nil
    }

    private static func displayValue(_ value: JSONValue?) -> String? {
        guard let value else { return nil }

        switch value {
        case .string(let string):
            return string
        case .integer(let integer):
            return String(integer)
        case .double(let double):
            return String(double)
        case .boolean(let boolean):
            return String(boolean)
        case .null:
            return nil
        case .object(let object):
            for key in ["name", "login", "full_name", "title", "ref"] {
                if let result = displayValue(object[key]) {
                    return result
                }
            }
            return nil
        case .array(let values):
            return values.compactMap { displayValue($0) }.joined(separator: ", ")
        }
    }

    private static func unknownPayloadItems(_ payload: JSONValue) -> [EventDetailItem] {
        guard case .object(let object) = payload else { return [] }

        return object.keys.sorted().prefix(8).compactMap { key in
            guard let value = displayValue(object[key]) else { return nil }

            return EventDetailItem(
                title: key.replacingOccurrences(of: "_", with: " ").capitalized,
                value: value,
                url: nil
            )
        }
    }
}
