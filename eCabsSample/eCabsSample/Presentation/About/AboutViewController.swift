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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupUI()
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
