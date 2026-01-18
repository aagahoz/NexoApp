//
//  StatusCardView.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 17.01.2026.
//

import UIKit

final class StatusCardView: UIView {

    private let iconImageView = UIImageView()
    private let countLabel = UILabel()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(status: JobApplicationStatus, count: Int) {
        titleLabel.text = status.displayTitle
        countLabel.text = "\(count)"

        iconImageView.image = UIImage(systemName: status.symbolName)
        iconImageView.tintColor = status.displayColor
    
        countLabel.textColor = status.displayColor
    }

    private func setupLayout() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 6

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(countLabel)
        stackView.addArrangedSubview(titleLabel)

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    private func setupAppearance() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12

        iconImageView.contentMode = .scaleAspectFit

        countLabel.font = .preferredFont(forTextStyle: .title2)

        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel
        
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
    }
}
