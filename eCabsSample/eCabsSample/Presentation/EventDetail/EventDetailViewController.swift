//
//  EventDetailViewController.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Visualizza le informazioni dell'evento.
//
//  EventDetailViewController.swift
//  eCabsSample

//  **EN:** Displays detailed information about a GitHub event.

//  **IT:** Mostra le informazioni dettagliate di un evento GitHub.

import UIKit

@MainActor
final class EventDetailViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var eventTypeLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var visibilityLabel: UILabel!
    @IBOutlet private weak var repositoryTitleLabel: UILabel!
    @IBOutlet private weak var repositoryButton: UIButton!
    @IBOutlet private weak var detailsStackView: UIStackView!

    // MARK: - Properties

    private let viewModel: EventDetailViewModel
    private let avatarLoader: AvatarLoader

    private var avatarTask: Task<Void, Never>?

    // MARK: - Initialization

    init(viewModel: EventDetailViewModel, avatarLoader: AvatarLoader) {
        self.viewModel = viewModel
        self.avatarLoader = avatarLoader
        super.init(nibName: "EventDetailViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        avatarTask?.cancel()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupUI()
        configureEvent()
        configureDetails()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = String(localized: "event_detail.navigation.title")
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        avatarImageView.layer.cornerRadius = 28
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = .secondarySystemBackground
        avatarImageView.image = UIImage(systemName: "person.crop.circle")

        loginLabel.font = .preferredFont(forTextStyle: .headline)
        loginLabel.adjustsFontForContentSizeCategory = true

        eventTypeLabel.font = .preferredFont(forTextStyle: .subheadline)
        eventTypeLabel.textColor = .secondaryLabel
        eventTypeLabel.adjustsFontForContentSizeCategory = true

        dateLabel.font = .preferredFont(forTextStyle: .footnote)
        dateLabel.textColor = .secondaryLabel
        dateLabel.adjustsFontForContentSizeCategory = true

        visibilityLabel.font = .preferredFont(forTextStyle: .footnote)
        visibilityLabel.textColor = .secondaryLabel
        visibilityLabel.adjustsFontForContentSizeCategory = true

        repositoryTitleLabel.font = .preferredFont(forTextStyle: .headline)
        repositoryTitleLabel.adjustsFontForContentSizeCategory = true
    }

    // MARK: - Configuration

    private func configureEvent() {
        loginLabel.text = viewModel.actorName
        eventTypeLabel.text = viewModel.eventType
        dateLabel.text = viewModel.eventDate
        visibilityLabel.text = viewModel.isPublic
        repositoryTitleLabel.text = viewModel.repositoryName

        repositoryButton.setTitle(
            String(localized: "event_detail.open_repository"),
            for: .normal
        )

        loadAvatar()
    }

    private func configureDetails() {
        // Remove existing content to avoid duplicated sections.
        for view in detailsStackView.arrangedSubviews {
            detailsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for section in viewModel.sections {
            let sectionStack = UIStackView()
            sectionStack.axis = .vertical
            sectionStack.spacing = 12

            let titleLabel = UILabel()
            titleLabel.text = section.title
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.numberOfLines = 0

            sectionStack.addArrangedSubview(titleLabel)

            for item in section.items {
                let row = UIStackView()
                row.axis = .vertical
                row.spacing = 4

                let itemTitle = UILabel()
                itemTitle.text = item.title
                itemTitle.font = .preferredFont(forTextStyle: .caption1)
                itemTitle.textColor = .secondaryLabel
                itemTitle.adjustsFontForContentSizeCategory = true

                let itemValue = UILabel()
                itemValue.text = item.value
                itemValue.font = .preferredFont(forTextStyle: .body)
                itemValue.numberOfLines = 0
                itemValue.adjustsFontForContentSizeCategory = true
                itemValue.lineBreakMode = .byWordWrapping

                row.addArrangedSubview(itemTitle)
                row.addArrangedSubview(itemValue)

                sectionStack.addArrangedSubview(row)
            }

            detailsStackView.addArrangedSubview(sectionStack)
        }
    }

    // MARK: - Avatar

    private func loadAvatar() {
        guard let url = viewModel.actorAvatarURL else { return }

        avatarTask?.cancel()

        avatarTask = Task { [weak self] in
            guard let self else { return }

            let image = await avatarLoader.loadImage(from: url)

            guard !Task.isCancelled else { return }

            avatarImageView.image = image ?? UIImage(
                systemName: "person.crop.circle"
            )
        }
    }

    // MARK: - Actions

    @IBAction private func repositoryButtonTapped(_ sender: UIButton) {
        UIApplication.shared.open(viewModel.repositoryURL)
    }
}
