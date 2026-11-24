//
//  AboutView.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 23/11/2026.
//


import SwiftUI

struct AboutView: View {

    // MARK: - Properties

    private let tokenStore = GitHubTokenStore()

    @State private var token = ""
    @State private var tokenConfigured = false
    @State private var tokenStatus = ""
    @State private var tokenStatusColor: Color = .secondary
    @State private var isSaving = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                informationSection
                tokenSection
                footerSection
            }
            .padding()
        }
        .navigationTitle(String(localized: "about.navigation.title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await updateTokenStatus()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image("gitHubLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)

            Text(String(localized: "about.title"))
                .font(.title2)
                .fontWeight(.bold)

            Text(appVersion)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(String(localized: "about.description"))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Information

    private var informationSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(String(localized: "about.supported_events.title"))
                    .font(.headline)

                Text(String(localized: "about.supported_events.description"))
                    .multilineTextAlignment(.center)
            }

            Text(String(localized: "about.technologies"))
                .multilineTextAlignment(.center)

            Link(
                String(localized: "about.api_button"),
                destination: URL(string: "https://docs.github.com/en/rest/activity/events")!
            )
        }
    }

    // MARK: - Token

    private var tokenSection: some View {
        VStack(spacing: 12) {
            Text(String(localized: "about.token.title"))
                .font(.headline)

            SecureField(
                String(localized: "about.token.placeholder"),
                text: $token
            )
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            HStack(spacing: 12) {
                Button {
                    Task {
                        await saveToken()
                    }
                } label: {
                    Text(String(localized: "about.token.save"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaving)

                Button {
                    Task {
                        await removeToken()
                    }
                } label: {
                    Text(String(localized: "about.token.remove"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!tokenConfigured || isSaving)
            }

            if !tokenStatus.isEmpty {
                Text(tokenStatus)
                    .font(.footnote)
                    .foregroundStyle(tokenStatusColor)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        Text(String(localized: "about.footer"))
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Token Actions

    private func saveToken() async {
        let value = token.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty else {
            setTokenStatus(
                String(localized: "about.token.empty"),
                color: .secondary
            )
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await tokenStore.save(value)
            token = ""

            setTokenStatus(
                String(localized: "about.token.saved"),
                color: .green
            )

            await updateTokenStatus()
        } catch {
            setTokenStatus(
                String(localized: "about.token.error"),
                color: .red
            )
        }
    }

    private func removeToken() async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await tokenStore.delete()
            token = ""

            setTokenStatus(
                String(localized: "about.token.removed"),
                color: .secondary
            )

            await updateTokenStatus()
        } catch {
            setTokenStatus(
                String(localized: "about.token.error"),
                color: .red
            )
        }
    }

    private func updateTokenStatus() async {
        do {
            let storedToken = try await tokenStore.read()
            tokenConfigured = !(storedToken ?? "").isEmpty

            setTokenStatus(
                String(
                    localized: tokenConfigured
                        ? "about.token.configured"
                        : "about.token.not_configured"
                ),
                color: tokenConfigured ? .green : .secondary
            )
        } catch {
            setTokenStatus(
                String(localized: "about.token.error"),
                color: .red
            )
        }
    }

    private func setTokenStatus(
        _ message: String,
        color: Color
    ) {
        tokenStatus = message
        tokenStatusColor = color
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

        return String(
            format: String(localized: "about.version"),
            version,
            build
        )
    }
}

#Preview("Light Mode") {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.dark)
}
