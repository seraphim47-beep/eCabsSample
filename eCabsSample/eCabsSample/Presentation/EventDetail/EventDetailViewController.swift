//
//  EventDetailViewController.swift
//  eCabsSample
//
//  Created by Matteo Savoldelli on 13/11/2026.
//  Visualizza le informazioni dell'evento.
//

import UIKit

@MainActor
final class EventDetailViewController: UIViewController {

    private let viewModel: EventDetailViewModel

    init(viewModel: EventDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Event Detail"
        view.backgroundColor = .systemBackground
    }
}
