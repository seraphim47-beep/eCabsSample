//
//  EventsViewController.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Costruisce e gestisce la UITableView, i filtri e le interazioni.
//

import UIKit

@MainActor
final class EventsViewController: UIViewController {

    private let viewModel: EventsViewModel
    private let onSelectEvent: (GitHubEvent) -> Void

    init(viewModel: EventsViewModel, onSelectEvent: @escaping (GitHubEvent) -> Void) {
        self.viewModel = viewModel
        self.onSelectEvent = onSelectEvent

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    private func configureUI() {
        title = "GitHub Events"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
