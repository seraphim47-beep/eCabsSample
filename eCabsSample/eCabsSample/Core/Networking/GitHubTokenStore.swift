//
//  GitHubTokenStore.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 16/11/2026.

//  **EN:** An actor that asynchronously manages the Personal Access Token in the iOS Keychain. It exposes save, read, and delete operations. The token is stored as a `kSecClassGenericPassword` item and is accessible while the device is unlocked, on this device only.

//  **IT:** È un actor che gestisce in modo asincrono il Personal Access Token nel Keychain iOS. Espone le operazioni di salvataggio, lettura e cancellazione. Il token viene conservato come elemento `kSecClassGenericPassword` ed è accessibile quando il dispositivo è sbloccato, solo su quel dispositivo.

import Foundation
import Security

actor GitHubTokenStore {
    private var service = Bundle.main.bundleIdentifier ?? "GitHubEvents"
    private var account = "github-personal-access-token"
    
    init(
         service: String = Bundle.main.bundleIdentifier ?? "GitHubEvents",
         account: String = "github-personal-access-token"
     ) {
         self.service = service
         self.account = account
     }

    func save(_ token: String) throws {
        let data = Data(token.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            var newItem = query
            attributes.forEach { newItem[$0.key] = $0.value }

            let addStatus = SecItemAdd(newItem as CFDictionary, nil)

            guard addStatus == errSecSuccess else {
                throw KeychainError.saveFailed(addStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }

    func read() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.readFailed(status)
        }

        return token
    }

    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)
}
