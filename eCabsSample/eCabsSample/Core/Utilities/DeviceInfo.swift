//
//  DeviceInfo.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.

//  **IT:** Provides centralized information about the current device and its interface orientation. It identifies the device family (iPhone, iPad, Mac, Apple TV or Apple Vision) and exposes properties to determine whether the interface is in portrait or landscape mode. It also provides descriptive values for the device type and current orientation. This utility helps keep device-specific logic centralized and reusable across the application, particularly when adapting the user interface to different devices and screen orientations.

//  **EN:**  Fornisce un punto centralizzato per ottenere informazioni sul dispositivo corrente e sull'orientamento della sua interfaccia. Identifica la famiglia del dispositivo (iPhone, iPad, Mac, Apple TV o Apple Vision) ed espone proprietà per determinare se l'interfaccia si trova in modalità portrait o landscape. Fornisce inoltre descrizioni testuali del tipo di dispositivo e dell'orientamento corrente. Questa utility permette di centralizzare e riutilizzare la logica specifica del dispositivo all'interno dell'applicazione, in particolare per adattare l'interfaccia utente ai diversi dispositivi e orientamenti dello schermo.


import UIKit

enum DeviceInfo {

    // MARK: - Device Type

    static var userInterfaceIdiom: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }

    static var isPad: Bool {
        userInterfaceIdiom == .pad
    }

    static var isPhone: Bool {
        userInterfaceIdiom == .phone
    }

    static var isMac: Bool {
        userInterfaceIdiom == .mac
    }

    static var isTV: Bool {
        userInterfaceIdiom == .tv
    }

    static var isVision: Bool {
        userInterfaceIdiom == .vision
    }

    // MARK: - Interface Orientation

    static var interfaceOrientation: UIInterfaceOrientation {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: {
                $0.activationState == .foregroundActive
            })?
            .interfaceOrientation ?? .unknown
    }

    static var isPortrait: Bool {
        interfaceOrientation.isPortrait
    }

    static var isLandscape: Bool {
        interfaceOrientation.isLandscape
    }

    static var isPortraitUpsideDown: Bool {
        interfaceOrientation == .portraitUpsideDown
    }

    static var isLandscapeLeft: Bool {
        interfaceOrientation == .landscapeLeft
    }

    static var isLandscapeRight: Bool {
        interfaceOrientation == .landscapeRight
    }

    // MARK: - Orientation Description

    static var orientationDescription: String {
        switch interfaceOrientation {
        case .portrait:
            return "Portrait" // verticale

        case .portraitUpsideDown:
            return "Portrait Upside Down" // verticale invertito

        case .landscapeLeft:
            return "Landscape Left" // orizzontale sinistro

        case .landscapeRight:
            return "Landscape Right" // orizzontale destro

        default:
            return "Unknown" // socnosciuto
        }
    }

    // MARK: - Device Description

    static var deviceDescription: String {
        switch userInterfaceIdiom {
        case .phone:
            return "iPhone"

        case .pad:
            return "iPad"

        case .mac:
            return "Mac"

        case .tv:
            return "Apple TV"

        case .vision:
            return "Apple Vision"

        default:
            return "Unknown"
        }
    }
}
