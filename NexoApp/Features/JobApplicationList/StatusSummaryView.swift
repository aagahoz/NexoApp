//
//  StatusSummaryView.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 17.01.2026.
//

import UIKit

final class StatusSummaryView: UIView {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private var cards: [JobApplicationStatus: StatusCardView] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        createCards()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with applications: [JobApplication]) {
        let grouped = Dictionary(grouping: applications, by: { $0.status })

        for status in JobApplicationStatus.allCases {
            let count = grouped[status]?.count ?? 0
            cards[status]?.configure(status: status, count: count)
        }
    }

    private func setupLayout() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        scrollView.showsHorizontalScrollIndicator = false

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill

        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),

            stackView.heightAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.heightAnchor,
                constant: -24
            )
        ])
    }

    private func createCards() {
        JobApplicationStatus.allCases.forEach { status in
            let card = StatusCardView()
            card.configure(status: status, count: 0)

            // Kartın küçülmemesi için
            card.widthAnchor.constraint(equalToConstant: 100).isActive = true

            cards[status] = card
            stackView.addArrangedSubview(card)
        }
    }
}
