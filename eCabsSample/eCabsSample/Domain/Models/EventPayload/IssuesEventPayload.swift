//
//  IssuesEventPayload.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//  **EN:** Represents the payload of an `IssuesEvent`, including its action, issue data, assignees, and labels.

//  **IT:** Rappresenta il payload di un evento `IssuesEvent`, includendo l'azione eseguita, i dati della Issue, gli assegnatari e le etichette.

import Foundation

nonisolated struct IssuesEventPayload: Decodable, Sendable {

    let action: String
    let issue: JSONValue

    let assignee: JSONValue?
    let assignees: [JSONValue]?

    let label: JSONValue?
    let labels: [JSONValue]?
}
