//
//  AppCoordinator.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.

//  **IT:** Gestisce la navigazione tra lista e dettaglio.

//  **EN:** Handles navigation between the list and detail views.

import UIKit

@MainActor
final class AppCoordinator {

    private let window: UIWindow
    private var navigationController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let apiClient = GitHubAPIClient()
        let mergeEventsUseCase = MergeEventsUseCase()

        let repository = EventsRepository(
            apiClient: apiClient,
            mergeEventsUseCase: mergeEventsUseCase
        )

        let viewModel = EventsViewModel(repository: repository)

        let viewController = EventsViewController(
            viewModel: viewModel,
            onSelectEvent: { [weak self] event in
                self?.showEventDetail(event)
            },
            onShowAbout: { [weak self] in
                self?.showAbout()
            }
        )

        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Navigation

    private func showAbout() {
        let aboutViewController = AboutViewController()
        navigationController?.pushViewController(aboutViewController, animated: true)
    }

    private func showEventDetail(_ event: GitHubEvent) {
        // TODO: Implementare la navigazione al dettaglio dell'evento.
    }
}
