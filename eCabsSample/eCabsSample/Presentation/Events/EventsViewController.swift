//
//  EventsViewController.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Costruisce e gestisce la UITableView, i filtri e le interazioni.
//


import UIKit

@MainActor
final class EventsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var githubLogoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var messageContainerView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var filterSegmentedControl: UISegmentedControl!
    
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var footerStatusLabel: UILabel!
    @IBOutlet private weak var footerAttributionLabel: UILabel!
    
    // MARK: - Properties

    private let viewModel: EventsViewModel
    private let onSelectEvent: (GitHubEvent) -> Void
    private let onShowAbout: () -> Void
    private let avatarLoader: AvatarLoader

    private var events: [GitHubEvent] = []

    private let eventTypes = [
        "PushEvent",
        "PullRequestEvent",
        "IssuesEvent",
        "WatchEvent",
        "ForkEvent"
    ]

    private(set) var availableEventTypes: [String] = []

    // MARK: - Initialization

    init(viewModel: EventsViewModel, avatarLoader: AvatarLoader, onSelectEvent: @escaping (GitHubEvent) -> Void, onShowAbout: @escaping () -> Void) {
        self.viewModel = viewModel
        self.avatarLoader = avatarLoader
        self.onSelectEvent = onSelectEvent
        self.onShowAbout = onShowAbout
        super.init(nibName: "EventsViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupCollectionView()
        bindViewModel()
    }
    
    private func configureHeaderView() {
        titleLabel.text = String(localized: "header.title")
        subtitleLabel.text = String(localized: "header.subtitle")
    }
    
    private func configureActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .tintColor
        activityIndicator.stopAnimating()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if events.isEmpty && !viewModel.isLoading {
            Task {
                await viewModel.loadEvents()
            }
        } else {
            viewModel.resumePolling()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewModel.stopPolling()
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction private func infoButtonTapped(_ sender: UIButton) {
        // Mostra le informazioni sull'applicazione
        onShowAbout()
    }

    // MARK: - Setup

    private func setupUI() {
        setupFilterSegmentedControl()
        configureHeaderView()
        configureActivityIndicator()
        configureMessageView()
    }
    
    private func configureMessageView() {
        messageContainerView.isHidden = true

        messageLabel.font = .systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        retryButton.configuration = .filled()
        retryButton.configuration?.cornerStyle = .medium
        retryButton.setTitle(String(localized: "events.retry"), for: .normal)
        retryButton.addTarget(self, action: #selector(retryLoading), for: .touchUpInside)
        retryButton.isHidden = true
        messageContainerView.backgroundColor = .launchScreen
        messageContainerView.layer.cornerRadius = 16
        messageContainerView.layer.masksToBounds = true
    }

    private func setupFilterSegmentedControl() {
        filterSegmentedControl.addTarget(
            self,
            action: #selector(filterChanged),
            for: .valueChanged
        )

        updateFilterSegmentedControl()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: EventCollectionViewCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: EventCollectionViewCell.cellIdentifier)

        collectionView.isHidden = true
        collectionView.contentInset = .zero

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            self?.updateUI()
        }
    }

    // MARK: - UI Updates

    private func updateUI() {
        events = viewModel.events
        
        updateFilterSegmentedControl()

        activityIndicator.isHidden = !viewModel.isLoading
        
        if viewModel.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        if let errorMessage = viewModel.errorMessage {
            messageLabel.text = errorMessage
            messageContainerView.isHidden = false
            retryButton.isHidden = false
        } else if events.isEmpty && !viewModel.isLoading {
            if viewModel.selectedTypes.isEmpty {
                messageLabel.text = String(localized: "events.empty")
                retryButton.isHidden = false
            } else {
                messageLabel.text = String(localized: "events.empty_filter")
                retryButton.isHidden = true
            }

            messageContainerView.isHidden = false
        } else {
            messageContainerView.isHidden = true
            retryButton.isHidden = true
        }

        collectionView.isHidden = events.isEmpty
        
        updateFooter()

        reloadCollectionView()
    }

    @MainActor
    private func reloadCollectionView() {
        guard isViewLoaded else {
            return
        }

        guard collectionView.window != nil else {
            collectionView.reloadData()
            return
        }

        UIView.transition(
            with: collectionView,
            duration: 0.2,
            options: [.transitionCrossDissolve],
            animations: {
                self.collectionView.reloadData()
            }
        )
    }

    // MARK: - Actions

    @objc
    private func retryLoading() {
        Task {
            await viewModel.loadEvents()
        }
    }

    @objc private func filterChanged() {
        let selectedIndex = filterSegmentedControl.selectedSegmentIndex

        guard selectedIndex >= 0 else {
            return
        }

        if selectedIndex == 0 {
            viewModel.updateFilters([])
            return
        }

        let eventTypeIndex = selectedIndex - 1

        guard viewModel.availableEventTypes.indices.contains(eventTypeIndex) else {
            return
        }

        let selectedType = viewModel.availableEventTypes[eventTypeIndex]

        viewModel.updateFilters([selectedType])
    }

    // MARK: - Layout

    private func numberOfColumns(for width: CGFloat) -> Int {
        let isLandscape = DeviceInfo.isLandscape

        if DeviceInfo.isPad {
            let preferredColumns = isLandscape ? 4 : 3
            return min(preferredColumns, max(2, Int(width / 280)))
        }

        if DeviceInfo.isPhone {
            let preferredColumns = isLandscape ? 2 : 1
            return min(preferredColumns, max(1, Int(width / 280)))
        }

        return max(1, Int(width / 280))
    }
}

// MARK: - UICollectionViewDataSource

extension EventsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        events.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EventCollectionViewCell.cellIdentifier,
            for: indexPath
        ) as? EventCollectionViewCell else {
            return UICollectionViewCell()
        }

        let event = events[indexPath.item]
        cell.configure(with: event, avatarLoader: avatarLoader)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension EventsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard events.indices.contains(indexPath.item) else {
            return
        }

        onSelectEvent(events[indexPath.item])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EventsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let spacing: CGFloat = 12

        let availableWidth = collectionView.bounds.width
            - sectionInsets.left
            - sectionInsets.right

        let columns = numberOfColumns(for: availableWidth)
        let totalSpacing = CGFloat(columns - 1) * spacing
        let itemWidth = (availableWidth - totalSpacing) / CGFloat(columns)

        return CGSize(width: itemWidth, height: 140)
    }
    
    private func updateFooter() {
        let lastUpdated: String

        if let date = viewModel.lastUpdatedAt {
            lastUpdated = date.formatted(date: .omitted, time: .shortened)
        } else {
            lastUpdated = "--:--"
        }

        let pollInterval = viewModel.currentPollInterval
        
        let eventsCount = viewModel.events.count // maybe events/allEvents for filter info: 5/30 

        footerStatusLabel.text = String(format: String(localized: "events.footer.status"), eventsCount, lastUpdated, pollInterval, String(localized: "generic.not_available_short"))

        footerAttributionLabel.text = String(localized: "events.footer.attribution")
        
        footerView.addBorderTop(size: 1, color: .separator, opacity: 0.5, margin: 0)
        
        updateAuthStatus(eC: eventsCount, lU: lastUpdated, pI: pollInterval)
    }
    
    private func updateAuthStatus(eC: Int, lU: String, pI: Int)
    {
        Task {
            do {
                let token = try await GitHubTokenStore().read()
                let isConfigured = !(token ?? "").isEmpty
                let auth = String(
                    localized: isConfigured
                        ? "generic.authenticated"
                        : "generic.unauthenticated"
                )
                footerStatusLabel.text = String(format: String(localized: "events.footer.status"), eC, lU, pI, auth)
            } catch {

            }
        }
    }
    
    private func updateFilterSegmentedControl() {
        let selectedTypes = viewModel.selectedTypes

        filterSegmentedControl.removeAllSegments()

        filterSegmentedControl.insertSegment(
            withTitle: String(localized: "events.filter.all"),
            at: 0,
            animated: false
        )

        for (index, type) in viewModel.availableEventTypes.enumerated() {
            filterSegmentedControl.insertSegment(
                withTitle: localizedEventType(type),
                at: index + 1,
                animated: false
            )
        }

        if selectedTypes.isEmpty {
            filterSegmentedControl.selectedSegmentIndex = 0
        } else if let selectedType = selectedTypes.first,
                  let index = viewModel.availableEventTypes.firstIndex(of: selectedType) {
            filterSegmentedControl.selectedSegmentIndex = index + 1
        } else {
            filterSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    private func localizedEventType(_ type: String) -> String {
        let key: String

        switch type {
        case "CommitCommentEvent":
            key = "events.filter.commit_comment"
        case "CreateEvent":
            key = "events.filter.create"
        case "DeleteEvent":
            key = "events.filter.delete"
        case "DiscussionEvent":
            key = "events.filter.discussion"
        case "ForkEvent":
            key = "events.filter.fork"
        case "GollumEvent":
            key = "events.filter.gollum"
        case "IssueCommentEvent":
            key = "events.filter.issue_comment"
        case "IssuesEvent":
            key = "events.filter.issues"
        case "MemberEvent":
            key = "events.filter.member"
        case "PublicEvent":
            key = "events.filter.public"
        case "PullRequestEvent":
            key = "events.filter.pull_request"
        case "PullRequestReviewEvent":
            key = "events.filter.pull_request_review"
        case "PullRequestReviewCommentEvent":
            key = "events.filter.pull_request_review_comment"
        case "PushEvent":
            key = "events.filter.push"
        case "ReleaseEvent":
            key = "events.filter.release"
        case "WatchEvent":
            key = "events.filter.watch"
        default:
            return type.replacingOccurrences(of: "Event", with: "")
        }

        return String(localized: String.LocalizationValue(key))
    }
}
