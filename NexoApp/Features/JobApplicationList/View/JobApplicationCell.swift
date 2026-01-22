//
//  JobApplicationCell.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

final class JobApplicationCell: UITableViewCell {

    static let reuseIdentifier = "JobApplicationCell"

    // MARK: - Layout

    private enum Layout {
        // Cell -> Card spacing
        static let cardTopBottomInset: CGFloat = 8
        static let cardSideInset: CGFloat = 16
        static let cardInnerPadding: CGFloat = 14

        // Card visuals
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1

        // Root layout
        static let horizontalSpacing: CGFloat = 14
        static let textSpacing: CGFloat = 6
        static let titleStatusSpacing: CGFloat = 10

        // Left logo box
        static let logoBoxSize: CGFloat = 56
        static let logoBoxCornerRadius: CGFloat = 14
        static let logoIconSize: CGFloat = 22

        // Status pill
        static let pillHeight: CGFloat = 20
        static let pillHorizontalPadding: CGFloat = 8
        static let pillCornerRadius: CGFloat = 10
        static let pillIconSize: CGFloat = 12
        static let pillSpacing: CGFloat = 6

        // Meta row
        static let metaRowSpacing: CGFloat = 6
        static let dotFontSize: CGFloat = 14

        // Progress
        static let progressTopSpacing: CGFloat = 10
        static let progressBarHeight: CGFloat = 3
        static let progressBarCornerRadius: CGFloat = 2

        // Fonts
        static let phaseFont = UIFont.systemFont(ofSize: 11, weight: .bold)
        static let pillFont = UIFont.systemFont(ofSize: 10, weight: .bold)
        static let metaFont = UIFont.preferredFont(forTextStyle: .subheadline)

        // Colors (centralize so styling is consistent)
        static let cardBackground = UIColor.white.withAlphaComponent(0.06)
        static let cardBorder = UIColor.white.withAlphaComponent(0.08)
        static let selectedCardBackground = UIColor.white.withAlphaComponent(0.08)
        static let selectedCardBorder = UIColor.white.withAlphaComponent(0.12)

        static let companyText = UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1) // slate-400 feel
        static let locationText = UIColor.white.withAlphaComponent(0.55)
        static let dotText = UIColor.white.withAlphaComponent(0.35)
        static let phaseText = UIColor.white.withAlphaComponent(0.45)

        static let progressTrack = UIColor.white.withAlphaComponent(0.08)
    }

    // MARK: - Views

    private let cardView = UIView()

    // Selected background (aligned to card inset to avoid “outside highlight”)
    private let selectedContainerView = UIView()
    private let selectedCardView = UIView()

    // Root stacks
    private let horizontalStack = UIStackView()
    private let contentStack = UIStackView()
    private let titleRowStack = UIStackView()
    private let metaRowStack = UIStackView()
    private let progressRow = UIStackView()

    // Left logo box
    private let logoContainerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = Layout.logoBoxCornerRadius
        v.layer.cornerCurve = .continuous
        v.clipsToBounds = true
        return v
    }()

    private let logoGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 51/255, green: 65/255, blue: 85/255, alpha: 1).cgColor,  // slate-700
            UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1).cgColor   // slate-900
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private let logoIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: Layout.logoIconSize,
            weight: .semibold
        )
        iv.tintColor = UIColor.white.withAlphaComponent(0.9)
        return iv
    }()

    // Title row
    private let titleLabel = UILabel()
    private let titleSpacer = UIView()

    private let statusPillView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = Layout.pillCornerRadius
        v.layer.cornerCurve = .continuous
        v.clipsToBounds = true
        return v
    }()

    private let statusStack = UIStackView()
    private let statusIcon = UIImageView()
    private let statusLabel = UILabel()

    // Meta row: Company • Location (left aligned)
    private let companyLabel = UILabel()

    private let dotLabel: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: Layout.dotFontSize, weight: .regular)
        label.textColor = Layout.dotText
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let locationLabel = UILabel()
    private let metaTrailingSpacer = UIView()

    // Progress
    private let progressTrackView = UIView()
    private let progressFillView = UIView()
    private let phaseLabel = UILabel()

    private var progress: CGFloat = 0
    private var fillWidthConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Updates

    override func layoutSubviews() {
        super.layoutSubviews()

        // Keep gradient matched to its container
        logoGradientLayer.frame = logoContainerView.bounds

        // Update progress fill width after layout
        let trackWidth = progressTrackView.bounds.width
        fillWidthConstraint?.constant = max(0, min(trackWidth, trackWidth * progress))
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        companyLabel.text = nil
        locationLabel.text = nil

        statusLabel.text = nil
        statusLabel.textColor = .label
        statusIcon.image = nil
        statusIcon.tintColor = .label

        logoIconView.image = nil

        progress = 0
        phaseLabel.text = nil
        progressFillView.backgroundColor = .clear
        statusPillView.backgroundColor = .clear

        dotLabel.isHidden = true
    }

    // MARK: - Configure

    func configure(with jobApplication: JobApplication) {
        titleLabel.text = jobApplication.title
        companyLabel.text = jobApplication.company

        // TODO: modelinden gerçek değer ile doldur
        locationLabel.text = "Remote"

        let hasLocation = !(locationLabel.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ?? true)
        dotLabel.isHidden = !hasLocation

        let status = jobApplication.status

        statusLabel.text = status.displayTitle.uppercased()
        statusLabel.textColor = status.displayColor

        statusIcon.image = UIImage(systemName: status.symbolName)
        statusIcon.tintColor = status.displayColor

        statusPillView.backgroundColor = status.displayColor.withAlphaComponent(0.12)

        // Placeholder: later replace with real company logo
        logoIconView.image = UIImage(systemName: status.symbolName)

        let phase = phaseInfo(for: status)
        progress = phase.progress
        phaseLabel.text = "PHASE \(phase.current)/\(phase.total)"
        progressFillView.backgroundColor = status.displayColor

        setNeedsLayout()
    }

    private func phaseInfo(for status: JobApplicationStatus) -> (current: Int, total: Int, progress: CGFloat) {
        let total = 4
        switch status {
        case .notApplied: return (1, total, 0.10)
        case .applied:    return (2, total, 0.45)
        case .reviewing:  return (3, total, 0.75)
        case .accepted:   return (4, total, 1.00)
        case .rejected:   return (4, total, 1.00)
        }
    }

    // MARK: - Build Layout

    private func setupLayout() {
        selectionStyle = .default
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupCard()
        setupRootStacks()
        setupLogo()
        setupTitleRow()
        setupMetaRow()
        setupProgressRow()
        assemble()
    }

    private func setupCard() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cardTopBottomInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cardTopBottomInset),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cardSideInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.cardSideInset)
        ])
    }

    private func setupRootStacks() {
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .top
        horizontalStack.spacing = Layout.horizontalSpacing
        horizontalStack.distribution = .fill

        cardView.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Layout.cardInnerPadding),
            horizontalStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.cardInnerPadding),
            horizontalStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.cardInnerPadding),
            horizontalStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Layout.cardInnerPadding)
        ])

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = Layout.textSpacing
    }

    private func setupLogo() {
        logoContainerView.layer.insertSublayer(logoGradientLayer, at: 0)
        logoContainerView.addSubview(logoIconView)
        logoIconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoContainerView.widthAnchor.constraint(equalToConstant: Layout.logoBoxSize),
            logoContainerView.heightAnchor.constraint(equalToConstant: Layout.logoBoxSize),
            logoIconView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoIconView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor)
        ])
    }

    private func setupTitleRow() {
        titleRowStack.axis = .horizontal
        titleRowStack.alignment = .top
        titleRowStack.distribution = .fill
        titleRowStack.spacing = Layout.titleStatusSpacing

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // pushes pill to the right
        titleSpacer.setContentHuggingPriority(.required, for: .horizontal)
        titleSpacer.setContentCompressionResistancePriority(.required, for: .horizontal)

        statusPillView.setContentHuggingPriority(.required, for: .horizontal)
        statusPillView.setContentCompressionResistancePriority(.required, for: .horizontal)

        statusStack.axis = .horizontal
        statusStack.alignment = .center
        statusStack.distribution = .fill
        statusStack.spacing = Layout.pillSpacing

        statusIcon.contentMode = .scaleAspectFit
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusIcon.widthAnchor.constraint(equalToConstant: Layout.pillIconSize),
            statusIcon.heightAnchor.constraint(equalToConstant: Layout.pillIconSize)
        ])

        statusLabel.font = Layout.pillFont
        statusLabel.numberOfLines = 1

        statusStack.addArrangedSubview(statusIcon)
        statusStack.addArrangedSubview(statusLabel)

        statusPillView.addSubview(statusStack)
        statusStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            statusStack.topAnchor.constraint(equalTo: statusPillView.topAnchor),
            statusStack.bottomAnchor.constraint(equalTo: statusPillView.bottomAnchor),
            statusStack.leadingAnchor.constraint(equalTo: statusPillView.leadingAnchor, constant: Layout.pillHorizontalPadding),
            statusStack.trailingAnchor.constraint(equalTo: statusPillView.trailingAnchor, constant: -Layout.pillHorizontalPadding),
            statusPillView.heightAnchor.constraint(equalToConstant: Layout.pillHeight)
        ])
    }

    private func setupMetaRow() {
        metaRowStack.axis = .horizontal
        metaRowStack.alignment = .firstBaseline
        metaRowStack.distribution = .fill
        metaRowStack.spacing = Layout.metaRowSpacing

        companyLabel.font = Layout.metaFont
        companyLabel.textColor = Layout.companyText
        companyLabel.numberOfLines = 1
        companyLabel.lineBreakMode = .byTruncatingTail
        companyLabel.setContentHuggingPriority(.required, for: .horizontal)
        companyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        locationLabel.font = Layout.metaFont
        locationLabel.textColor = Layout.locationText
        locationLabel.numberOfLines = 1
        locationLabel.textAlignment = .left
        locationLabel.lineBreakMode = .byTruncatingTail
        locationLabel.setContentHuggingPriority(.required, for: .horizontal)
        locationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // takes remaining space so company • location stays visually on the left
        metaTrailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        metaTrailingSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func setupProgressRow() {
        progressRow.axis = .horizontal
        progressRow.alignment = .center
        progressRow.distribution = .fill
        progressRow.spacing = 10

        progressTrackView.backgroundColor = Layout.progressTrack
        progressTrackView.layer.cornerRadius = Layout.progressBarCornerRadius
        progressTrackView.clipsToBounds = true
        progressTrackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressTrackView.heightAnchor.constraint(equalToConstant: Layout.progressBarHeight)
        ])

        progressFillView.layer.cornerRadius = Layout.progressBarCornerRadius
        progressFillView.clipsToBounds = true
        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        progressTrackView.addSubview(progressFillView)

        fillWidthConstraint = progressFillView.widthAnchor.constraint(equalToConstant: 0)
        fillWidthConstraint?.isActive = true

        NSLayoutConstraint.activate([
            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor)
        ])

        phaseLabel.font = Layout.phaseFont
        phaseLabel.textColor = Layout.phaseText
        phaseLabel.numberOfLines = 1
        phaseLabel.setContentHuggingPriority(.required, for: .horizontal)
        phaseLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        progressTrackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        progressTrackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func assemble() {
        // Title row
        titleRowStack.addArrangedSubview(titleLabel)
        titleRowStack.addArrangedSubview(titleSpacer)
        titleRowStack.addArrangedSubview(statusPillView)

        // Meta row
        metaRowStack.addArrangedSubview(companyLabel)
        metaRowStack.addArrangedSubview(dotLabel)
        metaRowStack.addArrangedSubview(locationLabel)
        metaRowStack.addArrangedSubview(metaTrailingSpacer)

        // Progress container (adds top breathing room like HTML mt-4)
        progressRow.addArrangedSubview(progressTrackView)
        progressRow.addArrangedSubview(phaseLabel)

        let progressContainer = UIStackView(arrangedSubviews: [progressRow])
        progressContainer.axis = .vertical
        progressContainer.spacing = 0
        progressContainer.isLayoutMarginsRelativeArrangement = true
        progressContainer.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Layout.progressTopSpacing,
            leading: 0,
            bottom: 0,
            trailing: 0
        )

        // Content stack
        contentStack.addArrangedSubview(titleRowStack)
        contentStack.addArrangedSubview(metaRowStack)
        contentStack.addArrangedSubview(progressContainer)

        // Root
        horizontalStack.addArrangedSubview(logoContainerView)
        horizontalStack.addArrangedSubview(contentStack)
    }

    // MARK: - Styling

    private func applyStyle() {
        // Card visuals
        cardView.backgroundColor = Layout.cardBackground
        cardView.layer.cornerRadius = Layout.cornerRadius
        cardView.layer.cornerCurve = .continuous
        cardView.layer.borderWidth = Layout.borderWidth
        cardView.layer.borderColor = Layout.cardBorder.cgColor

        // Selected visuals (only inside card inset)
        selectedContainerView.backgroundColor = .clear

        selectedCardView.backgroundColor = Layout.selectedCardBackground
        selectedCardView.layer.cornerRadius = Layout.cornerRadius
        selectedCardView.layer.cornerCurve = .continuous
        selectedCardView.layer.borderWidth = Layout.borderWidth
        selectedCardView.layer.borderColor = Layout.selectedCardBorder.cgColor

        selectedContainerView.addSubview(selectedCardView)
        selectedCardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            selectedCardView.topAnchor.constraint(equalTo: selectedContainerView.topAnchor, constant: Layout.cardTopBottomInset),
            selectedCardView.bottomAnchor.constraint(equalTo: selectedContainerView.bottomAnchor, constant: -Layout.cardTopBottomInset),
            selectedCardView.leadingAnchor.constraint(equalTo: selectedContainerView.leadingAnchor, constant: Layout.cardSideInset),
            selectedCardView.trailingAnchor.constraint(equalTo: selectedContainerView.trailingAnchor, constant: -Layout.cardSideInset)
        ])

        selectedBackgroundView = selectedContainerView
    }
}
