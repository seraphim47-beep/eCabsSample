//
//  SceneDelegate.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.

//  **IT:** Gestisce la finestra principale e avvia il Coordinator.

//  **EN:** Manages the main window and initializes the Coordinator.

import UIKit

@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        let coordinator = AppCoordinator(window: window)

        self.window = window
        self.coordinator = coordinator

        coordinator.start()
    }
}
