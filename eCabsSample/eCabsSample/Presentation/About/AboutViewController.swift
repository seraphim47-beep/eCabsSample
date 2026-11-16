//
//  AboutViewController.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//

import UIKit

@MainActor
final class AboutViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var gitHubLogo: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var supportedEventsTitleLabel: UILabel!
    @IBOutlet private weak var supportedEventsLabel: UILabel!
    @IBOutlet private weak var technologiesLabel: UILabel!
    @IBOutlet private weak var apiButton: UIButton!
    @IBOutlet private weak var footerLabel: UILabel!
    @IBOutlet private weak var contentStackView: UIStackView!

    // MARK: - Properties

    private let tokenStore = GitHubTokenStore()

    private let tokenTitleLabel = UILabel()
    private let tokenTextField = UITextField()
    private let tokenStatusLabel = UILabel()
    private let saveTokenButton = UIButton(type: .system)
    private let removeTokenButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupUI()
        setupTokenSection()
        updateTokenStatus()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = String(localized: "about.navigation.title")
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        setupLabels()
        setupButton()
    }

    private func setupLabels() {
        titleLabel.text = String(localized: "about.title")
        versionLabel.text = appVersion
        descriptionLabel.text = String(localized: "about.description")
        supportedEventsTitleLabel.text = String(localized: "about.supported_events.title")
        supportedEventsLabel.text = String(localized: "about.supported_events.description")
        technologiesLabel.text = String(localized: "about.technologies")
        footerLabel.text = String(localized: "about.footer")

        [descriptionLabel, supportedEventsLabel, technologiesLabel, footerLabel].forEach {
            $0?.numberOfLines = 0
        }

        [titleLabel, versionLabel, descriptionLabel, supportedEventsTitleLabel, supportedEventsLabel, technologiesLabel, footerLabel].forEach {
            $0?.textAlignment = .center
        }
    }

    private func setupButton() {
        apiButton.setTitle(String(localized: "about.api_button"), for: .normal)
    }

    // MARK: - Token Section

    private func setupTokenSection() {
        let section = UIStackView()
        section.axis = .vertical
        section.alignment = .fill
        section.spacing = 10

        tokenTitleLabel.text = String(localized: "about.token.title")
        tokenTitleLabel.font = .preferredFont(forTextStyle: .headline)
        tokenTitleLabel.textAlignment = .center

        tokenTextField.placeholder = String(localized: "about.token.placeholder")
        tokenTextField.borderStyle = .roundedRect
        tokenTextField.isSecureTextEntry = true
        tokenTextField.autocorrectionType = .no
        tokenTextField.autocapitalizationType = .none
        tokenTextField.textContentType = .password
        tokenTextField.clearButtonMode = .whileEditing

        tokenStatusLabel.font = .preferredFont(forTextStyle: .footnote)
        tokenStatusLabel.textAlignment = .center
        tokenStatusLabel.numberOfLines = 0

        saveTokenButton.setTitle(String(localized: "about.token.save"), for: .normal)
        saveTokenButton.addTarget(self, action: #selector(saveTokenTapped), for: .touchUpInside)

        removeTokenButton.setTitle(String(localized: "about.token.remove"), for: .normal)
        removeTokenButton.addTarget(self, action: #selector(removeTokenTapped), for: .touchUpInside)

        let buttonsStack = UIStackView(arrangedSubviews: [saveTokenButton, removeTokenButton])
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 12

        section.addArrangedSubview(tokenTitleLabel)
        section.addArrangedSubview(tokenTextField)
        section.addArrangedSubview(buttonsStack)
        section.addArrangedSubview(tokenStatusLabel)

        contentStackView.insertArrangedSubview(section, at: 7)
    }

    // MARK: - Token Actions

    @objc private func saveTokenTapped() {
        let token = tokenTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !token.isEmpty else {
            tokenStatusLabel.text = String(localized: "about.token.empty")
            return
        }

        Task {
            do {
                try await tokenStore.save(token)
                tokenTextField.text = nil
                tokenStatusLabel.text = String(localized: "about.token.saved")
                tokenStatusLabel.textColor = .systemGreen
            } catch {
                tokenStatusLabel.text = String(localized: "about.token.error")
                tokenStatusLabel.textColor = .systemRed
            }
        }
    }

    @objc private func removeTokenTapped() {
        Task {
            do {
                try await tokenStore.delete()
                tokenTextField.text = nil
                tokenStatusLabel.text = String(localized: "about.token.removed")
                tokenStatusLabel.textColor = .secondaryLabel
            } catch {
                tokenStatusLabel.text = String(localized: "about.token.error")
                tokenStatusLabel.textColor = .systemRed
            }
        }
    }

    private func updateTokenStatus() {
        Task {
            do {
                let token = try await tokenStore.read()
                let isConfigured = !(token ?? "").isEmpty

                tokenStatusLabel.text = String(
                    localized: isConfigured ? "about.token.configured" : "about.token.not_configured"
                )
                tokenStatusLabel.textColor = isConfigured ? .systemGreen : .secondaryLabel
                removeTokenButton.isEnabled = isConfigured
            } catch {
                tokenStatusLabel.text = String(localized: "about.token.error")
                tokenStatusLabel.textColor = .systemRed
            }
        }
    }

    // MARK: - Actions

    @IBAction private func apiButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: "https://docs.github.com/en/rest/activity/events") else {
            return
        }

        UIApplication.shared.open(url)
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
