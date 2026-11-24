
//
//  AppCoordinator.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//
//  **IT:** Gestisce la navigazione tra lista e dettaglio.

//  **EN:** Handles navigation between the list and detail views.
//

import UIKit
import SwiftUI

@MainActor
final class AppCoordinator {

    // MARK: - Properties

    private let window: UIWindow
    private var navigationController: UINavigationController?
    private let avatarLoader = AvatarLoader() // handle avatar images and cache
    private var SUI = true
    
    // MARK: - Initialization

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Start

    func start() {
        let apiClient = GitHubAPIClient()
        let mergeEventsUseCase = MergeEventsUseCase()
        let repository = EventsRepository(apiClient: apiClient, mergeEventsUseCase: mergeEventsUseCase)

        let viewModel = EventsViewModel(repository: repository)

        let viewController = EventsViewController(
            viewModel: viewModel,
            avatarLoader: avatarLoader,
            onSelectEvent: { [weak self] event in
                self?.showEventDetail(event)
            },
            onShowAbout: { [weak self] in
                self?.showAbout()
            }
        )

        let navigationController = UINavigationController(
            rootViewController: viewController
        )

        self.navigationController = navigationController

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Navigation

    // Oper about page
    private func showAbout() {
        if SUI
        {
            let aboutView = AboutView()

            let aboutViewController = UIHostingController(
                rootView: aboutView
            )

            navigationController?.pushViewController(
                aboutViewController,
                animated: true
            )
        }
        else
        {
            let aboutViewController = AboutViewController()
            navigationController?.pushViewController(
                aboutViewController,
                animated: true
            )
        }
    }

    // Open eventdetail page
    private func showEventDetail(_ event: GitHubEvent) {
        let viewModel = EventDetailViewModel(event: event)

        let viewController = EventDetailViewController(
            viewModel: viewModel,
            avatarLoader: avatarLoader
        )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}

