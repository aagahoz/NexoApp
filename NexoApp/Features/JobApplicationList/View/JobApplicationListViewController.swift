//
//  JobApplicationListViewController.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

@MainActor
final class JobApplicationListViewController: GradientViewController {

    // MARK: - Dependencies

    private let viewModel: JobApplicationListViewModel
    private let showsLoginButton: Bool

    // MARK: - State

    private var currentState: JobApplicationListViewState = .loading

    // MARK: - Callbacks

    var onLoginTapped: (() -> Void)?
    var onLogoutTapped: (() -> Void)?

    // MARK: - UI

    private enum Layout {
        static let summaryHeight: CGFloat = 128
        static let headerTopPadding: CGFloat = 32
        static let headerHorizontalPadding: CGFloat = 16
        static let headerBottomPadding: CGFloat = 8
        static let dividerHeight: CGFloat = 1 / UIScreen.main.scale

        static let headerBottomSpacingToTable: CGFloat = 8
    }

    // Header içerikleri (table header içinde yaşayacak)
    private let summaryView = StatusSummaryView()

    private let activityHeaderView = UIView()

    private let activityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent Activities"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let activityDividerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.00)
        return v
    }()

    // Table
    private let tableView = UITableView()

    // Overlays
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No Application found"
        label.textAlignment = .center
        label.isHidden = true
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Table Header Container

    private let headerContainerView = UIView()
    private let headerStack = UIStackView()

    // Header’ın görünür olup olmadığını tek yerden yönetelim
    private var isHeaderVisible: Bool = false {
        didSet { updateTableHeaderVisibility() }
    }

    // MARK: - Init

    init(viewModel: JobApplicationListViewModel, showsLoginButton: Bool) {
        self.viewModel = viewModel
        self.showsLoginButton = showsLoginButton
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAppearance()
        configureNavigationBar()
        configureTableView()
        configureOverlays()
        configureTableHeader()
        bindViewModel()

        Task { await viewModel.load() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await viewModel.load() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // tableHeaderView Auto Layout ile otomatik boyutlanmadığı için
        // her layout sonrası header yüksekliğini güncelliyoruz.
        updateTableHeaderHeightIfNeeded()
    }

    // MARK: - Configure

    private func configureAppearance() {
        title = "Applications"
        view.backgroundColor = .clear
    }

    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: showsLoginButton ? "Login" : "Logout",
            style: .plain,
            target: self,
            action: showsLoginButton ? #selector(loginTapped) : #selector(logoutTapped)
        )
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            JobApplicationCell.self,
            forCellReuseIdentifier: JobApplicationCell.reuseIdentifier
        )

        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 92

        tableView.backgroundColor = .clear
    }

    private func configureOverlays() {
        view.addSubview(emptyLabel)
        view.addSubview(loadingIndicator)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        emptyLabel.isHidden = true
        loadingIndicator.stopAnimating()
    }

    private func configureTableHeader() {
        // 1) activityHeaderView içini kur
        activityHeaderView.backgroundColor = .clear
        activityHeaderView.addSubview(activityTitleLabel)
        activityHeaderView.addSubview(activityDividerView)

        activityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityDividerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityTitleLabel.topAnchor.constraint(equalTo: activityHeaderView.topAnchor),
            activityTitleLabel.leadingAnchor.constraint(equalTo: activityHeaderView.leadingAnchor, constant: Layout.headerHorizontalPadding),
            activityTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: activityHeaderView.trailingAnchor, constant: -Layout.headerHorizontalPadding),

            activityDividerView.topAnchor.constraint(equalTo: activityTitleLabel.bottomAnchor, constant: Layout.headerBottomPadding),
            activityDividerView.leadingAnchor.constraint(equalTo: activityHeaderView.leadingAnchor, constant: Layout.headerHorizontalPadding),
            activityDividerView.trailingAnchor.constraint(equalTo: activityHeaderView.trailingAnchor, constant: -Layout.headerHorizontalPadding),
            activityDividerView.heightAnchor.constraint(equalToConstant: Layout.dividerHeight),
            activityDividerView.bottomAnchor.constraint(equalTo: activityHeaderView.bottomAnchor)
        ])

        // 2) headerStack kur (summary + header + biraz spacing)
        headerStack.axis = .vertical
        headerStack.alignment = .fill
        headerStack.distribution = .fill
        headerStack.spacing = 0

        headerContainerView.addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            headerStack.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ])

        // Summary sabit yükseklik
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        summaryView.heightAnchor.constraint(equalToConstant: Layout.summaryHeight).isActive = true

        // Header’ı summary’den sonra aşağı itmek için padding hissi
        let headerTopSpacer = UIView()
        headerTopSpacer.translatesAutoresizingMaskIntoConstraints = false
        headerTopSpacer.heightAnchor.constraint(equalToConstant: Layout.headerTopPadding).isActive = true

        let headerBottomSpacer = UIView()
        headerBottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        headerBottomSpacer.heightAnchor.constraint(equalToConstant: Layout.headerBottomSpacingToTable).isActive = true

        headerStack.addArrangedSubview(summaryView)
        headerStack.addArrangedSubview(headerTopSpacer)
        headerStack.addArrangedSubview(activityHeaderView)
        headerStack.addArrangedSubview(headerBottomSpacer)

        // 3) tableHeaderView olarak bağla
        tableView.tableHeaderView = headerContainerView

        // İlk açılışta header’ı gizleyelim (state’e göre açacağız)
        isHeaderVisible = false
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            self.currentState = state
            self.render(state)
        }
    }

    // MARK: - Actions

    @objc private func addTapped() {
        viewModel.onAddTapped?()
    }

    @objc private func loginTapped() {
        onLoginTapped?()
    }

    @objc private func logoutTapped() {
        onLogoutTapped?()
    }

    // MARK: - Dynamic Title

    private func setActivityTitle(_ title: String) {
        UIView.transition(with: activityTitleLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.activityTitleLabel.text = title
        }
    }

    // MARK: - Render

    private func render(_ state: JobApplicationListViewState) {
        switch state {

        case .loading:
            isHeaderVisible = false
            setTableVisible(false)
            setEmptyVisible(false)
            setLoadingVisible(true)

        case .empty:
            isHeaderVisible = false
            setTableVisible(false)
            setLoadingVisible(false)
            setEmptyVisible(true)

        case .loaded(let applications):
            isHeaderVisible = true
            setLoadingVisible(false)
            setEmptyVisible(false)
            setTableVisible(true)

            summaryView.update(applications: applications)
            setActivityTitle("Recent Activities")

            tableView.reloadData()
            updateTableHeaderHeightIfNeeded() // içerik değiştiği için header boyu güncellensin

        case .error(let message, let retry):
            isHeaderVisible = false
            setTableVisible(false)
            setEmptyVisible(false)
            setLoadingVisible(false)
            presentErrorAlert(message: message, retry: retry)
        }
    }

    // MARK: - Visibility Helpers

    private func setTableVisible(_ isVisible: Bool) {
        tableView.isHidden = !isVisible
    }

    private func setEmptyVisible(_ isVisible: Bool) {
        emptyLabel.isHidden = !isVisible
    }

    private func setLoadingVisible(_ isVisible: Bool) {
        if isVisible { loadingIndicator.startAnimating() }
        else { loadingIndicator.stopAnimating() }
    }

    // MARK: - Header Sizing (Critical)

    private func updateTableHeaderVisibility() {
        // tableHeaderView nil olursa header tamamen gider; tekrar set edilince geri gelir.
        // Bu yöntem hem performans hem de scroll davranışı açısından temiz.
        if isHeaderVisible {
            if tableView.tableHeaderView == nil {
                tableView.tableHeaderView = headerContainerView
            }
        } else {
            tableView.tableHeaderView = nil
        }
        updateTableHeaderHeightIfNeeded()
    }

    private func updateTableHeaderHeightIfNeeded() {
        guard isHeaderVisible else { return }
        guard tableView.tableHeaderView === headerContainerView else { return }

        // tableHeaderView genişliği tableView’a eşit olmalı ki Auto Layout doğru ölçsün.
        let targetWidth = tableView.bounds.width
        guard targetWidth > 0 else { return }

        headerContainerView.bounds = CGRect(
            x: 0,
            y: 0,
            width: targetWidth,
            height: headerContainerView.bounds.height
        )

        // Auto Layout ile gereken yüksekliği hesapla
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        let calculatedHeight = headerContainerView.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        // Yükseklik değiştiyse yeniden set et (tableHeaderView bunu istiyor)
        if headerContainerView.frame.height != calculatedHeight {
            headerContainerView.frame.size.height = calculatedHeight
            tableView.tableHeaderView = headerContainerView
        }
    }

    // MARK: - Error Alert

    private func presentErrorAlert(message: String, retry: (() -> Void)?) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

        if let retry {
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in retry() })
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension JobApplicationListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case let .loaded(applications) = currentState else { return 0 }
        return applications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: JobApplicationCell.reuseIdentifier,
                for: indexPath
            ) as? JobApplicationCell,
            case let .loaded(applications) = currentState
        else { return UITableViewCell() }

        cell.configure(with: applications[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension JobApplicationListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectJobApplication(at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            Task {
                await self?.viewModel.deleteJobApplication(at: indexPath.row)
                completion(true)
            }
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
