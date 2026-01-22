//
//  StatusCardCell.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 22.01.2026.
//

import UIKit

final class StatusCardCell: UICollectionViewCell {
    static let reuseIdentifier = "StatusCardCell"

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        return iv
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .leading
        s.distribution = .fill
        s.spacing = 6
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(countLabel)
        stack.addArrangedSubview(titleLabel)
        
        stack.setCustomSpacing(16, after: iconView)

        // Kartın iç padding’i: “count 3-4px içerde” hissi dahil hepsi içeriden başlasın.
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            iconView.heightAnchor.constraint(equalToConstant: 22),
            iconView.widthAnchor.constraint(equalToConstant: 22),
        ])
    }

    private func applyStyle() {
        // Basit ama kaliteli iskelet: radius + border, istersen sonra shadow ekleriz.
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 14
        contentView.layer.cornerCurve = .continuous

        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        contentView.clipsToBounds = true
    }

    func configure(with item: StatusSummaryItem) {
        let status = item.status
        iconView.image = UIImage(systemName: status.symbolName)
        iconView.tintColor = status.displayColor

        countLabel.text = "\(item.count)"
        titleLabel.text = status.displayTitle
    }
}
