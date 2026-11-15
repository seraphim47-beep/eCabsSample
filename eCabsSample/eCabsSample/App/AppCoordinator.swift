//
//  AppCoordinator.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Gestisce la navigazione tra lista e dettaglio.
//


import UIKit

@MainActor
final class AppCoordinator {

    private let window: UIWindow
    private let navigationController: UINavigationController

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        let viewModel = EventsViewModel()

        let viewController = EventsViewController(viewModel: viewModel, onSelectEvent: { [weak self] event in
                self?.showEventDetail(for: event)
            }
        )

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showEventDetail(for event: GitHubEvent) {
        let viewModel = EventDetailViewModel(event: event)
        let viewController = EventDetailViewController(
            viewModel: viewModel
        )

        navigationController.pushViewController(
            viewController,
            animated: true
        )
    }
}
