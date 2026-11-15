//
//  EventCollectionViewCell.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//

//
//  EventCollectionViewCell.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//

import UIKit

final class EventCollectionViewCell: UICollectionViewCell {
    
    static let nibName = "EventCollectionViewCell"
    static let cellIdentifier = "EventCollectionViewCell"

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var repositoryLabel: UILabel!
    @IBOutlet private weak var eventTypeLabel: UILabel!
    @IBOutlet private weak var eventDetailLabel: UILabel!
    @IBOutlet private weak var accessoryImageView: UIImageView!
    private var representedAvatarURL: URL?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarImageView.image = UIImage(systemName: "person.crop.circle")
        loginLabel.text = nil
        dateLabel.text = nil
        descriptionLabel.text = nil
        repositoryLabel.text = nil
        eventTypeLabel.text = nil
        eventDetailLabel.text = nil
        representedAvatarURL = nil
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 24
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UIImage(systemName: "person.crop.circle")
        avatarImageView.tintColor = .tertiaryLabel

        loginLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        loginLabel.textColor = .label
        loginLabel.numberOfLines = 1

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .right
        dateLabel.numberOfLines = 1
        
        eventTypeLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        eventTypeLabel.textColor = .secondaryLabel
        eventTypeLabel.numberOfLines = 1
        
        eventDetailLabel.font = .systemFont(ofSize: 12)
        eventDetailLabel.textColor = .secondaryLabel
        eventDetailLabel.textAlignment = .right
        eventDetailLabel.numberOfLines = 1

        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0

        repositoryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        repositoryLabel.textColor = .secondaryLabel
        repositoryLabel.numberOfLines = 1

        accessoryImageView.image = UIImage(systemName: "chevron.right")
        accessoryImageView.tintColor = .tertiaryLabel
        accessoryImageView.contentMode = .scaleAspectFit
    }
    
    func configure(with event: GitHubEvent, avatarLoader: AvatarLoader) {
        loginLabel.text = event.actor.login
        repositoryLabel.text = event.repository.name

        dateLabel.text = event.createdAt.formatted(
            date: .abbreviated,
            time: .shortened
        )

        eventTypeLabel.text = event.type
        descriptionLabel.text = eventDescription(for: event)
        eventDetailLabel.text = eventDetail(for: event)

        configureAvatar(with: event.actor.avatarURL, loader: avatarLoader)
        
        let color = eventColor(for: event.type)

        eventTypeLabel.textColor = color
    }
    
    func configureAvatar(with url: URL?, loader: AvatarLoader) {
        representedAvatarURL = url
        avatarImageView.image = UIImage(systemName: "person.crop.circle")

        guard let url else {
            return
        }

        Task { [weak self] in
            let image = await loader.loadImage(from: url)

            guard let self,
                  self.representedAvatarURL == url else {
                return
            }

            self.avatarImageView.image = image ?? UIImage(systemName: "person.crop.circle")
        }
    }
    
    private func eventDescription(for event: GitHubEvent) -> String {
        let key: String

        switch event.type {
        case "CommitCommentEvent":
            key = "events.description.commit_comment"
        case "CreateEvent":
            key = "events.description.create"
        case "DeleteEvent":
            key = "events.description.delete"
        case "DiscussionEvent":
            key = "events.description.discussion"
        case "ForkEvent":
            key = "events.description.fork"
        case "GollumEvent":
            key = "events.description.gollum"
        case "IssueCommentEvent":
            key = "events.description.issue_comment"
        case "IssuesEvent":
            key = "events.description.issues"
        case "MemberEvent":
            key = "events.description.member"
        case "PublicEvent":
            key = "events.description.public"
        case "PullRequestEvent":
            key = "events.description.pull_request"
        case "PullRequestReviewEvent":
            key = "events.description.pull_request_review"
        case "PullRequestReviewCommentEvent":
            key = "events.description.pull_request_review_comment"
        case "PushEvent":
            key = "events.description.push"
        case "ReleaseEvent":
            key = "events.description.release"
        case "WatchEvent":
            key = "events.description.watch"
        default:
            return event.type
        }

        return String(localized: String.LocalizationValue(key))
    }
    
    private func eventDetail(for event: GitHubEvent) -> String {
        switch event.payload {
        case .push(let payload):
            guard let ref = payload.ref else {
                return ""
            }

            let branch = ref.replacingOccurrences(
                of: "refs/heads/",
                with: ""
            )

            return String(
                format: String(localized: "events.detail.branch"),
                branch
            )

        case .pullRequest(let payload):
            let action = localizedAction(payload.action)

            return String(
                format: String(localized: "events.detail.pull_request"),
                payload.number,
                action
            )

        case .issues(let payload):
            return String(
                format: String(localized: "events.detail.issues"),
                localizedAction(payload.action)
            )

        case .watch(let payload):
            return localizedAction(payload.action)

        case .fork:
            return String(localized: "events.detail.fork")

        case .unknown:
            return ""
        }
    }

    private func localizedAction(_ action: String) -> String {
        let key = "events.action.\(action)"
        return String(localized: String.LocalizationValue(key))
    }
    
    private func eventColor(for type: String) -> UIColor {
        switch type {
        case "PushEvent":
            return UIColor(red: 35/255, green: 134/255, blue: 54/255, alpha: 1)
        case "PullRequestEvent":
            return UIColor(red: 130/255, green: 80/255, blue: 223/255, alpha: 1)
        case "IssuesEvent":
            return UIColor(red: 191/255, green: 135/255, blue: 0/255, alpha: 1)
        case "WatchEvent":
            return UIColor(red: 9/255, green: 105/255, blue: 218/255, alpha: 1)
        case "ForkEvent":
            return UIColor(red: 8/255, green: 145/255, blue: 178/255, alpha: 1)
        default:
            return .secondaryLabel
        }
    }
}
