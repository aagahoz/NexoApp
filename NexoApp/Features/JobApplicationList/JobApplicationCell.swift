//
//  JobApplicationCell.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

final class JobApplicationCell: UITableViewCell {

    static let reuseIdentifier = "JobApplicationCell"

    // MARK: - Layout Containers

    private let horizontalStack = UIStackView()
    private let textStack = UIStackView()
    private let statusStack = UIStackView()

    // MARK: - Text

    private let titleLabel = UILabel()
    private let companyLabel = UILabel()

    // MARK: - Status

    private let statusIcon = UIImageView()
    private let statusLabel = UILabel()
    
    // MARK: - Spacer
    
    private let spacer = UIView()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse Safety

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        companyLabel.text = nil

        statusLabel.text = nil
        statusLabel.textColor = .label
        statusIcon.image = nil
    }

    // MARK: - Configuration

    func configure(with jobApplication: JobApplication) {
        titleLabel.text = jobApplication.title
        companyLabel.text = jobApplication.company

        statusLabel.text = jobApplication.status.displayTitle
        statusLabel.textColor = jobApplication.status.displayColor

        statusIcon.image = UIImage(systemName: jobApplication.status.symbolName)
        statusIcon.tintColor = jobApplication.status.displayColor
    }

    // MARK: - Layout Setup

    private func setupLayout() {
        selectionStyle = .default

        // Root stack
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.spacing = 12

        contentView.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        // MARK: Text stack (flexible)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping

        companyLabel.font = .preferredFont(forTextStyle: .subheadline)
        companyLabel.textColor = .secondaryLabel
        companyLabel.numberOfLines = 1

        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(companyLabel)

        // Text stack can grow & shrink
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // MARK: spacer

        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // MARK: Status stack (fixed)

        statusIcon.contentMode = .scaleAspectFit
        statusIcon.setContentHuggingPriority(.required, for: .horizontal)

        statusLabel.font = .preferredFont(forTextStyle: .caption1)

        statusStack.axis = .horizontal
        statusStack.spacing = 4
        statusStack.alignment = .center
        statusStack.addArrangedSubview(statusIcon)
        statusStack.addArrangedSubview(statusLabel)

        // Status stack must stay compact
        statusStack.setContentHuggingPriority(.required, for: .horizontal)
        statusStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        // MARK: Assemble

        horizontalStack.addArrangedSubview(textStack)
        horizontalStack.addArrangedSubview(spacer)
        horizontalStack.addArrangedSubview(statusStack)
    }
}

