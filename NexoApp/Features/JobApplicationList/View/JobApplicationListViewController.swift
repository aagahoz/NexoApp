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
    }

    private let summaryView = StatusSummaryView()

    // Recent Activity header area
    private let activityHeaderView = UIView()

    private let activityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent Activity"
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

    private let tableView = UITableView()

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
        configureHierarchy()
        configureConstraints()
        configureActivityHeader()
        configureTableView()
        configureOverlays()
        bindViewModel()

        Task { await viewModel.load() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await viewModel.load() }
    }

    // MARK: - Configure

    private func configureAppearance() {
        title = "Job Applications"
        tableView.backgroundColor = .clear
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

    private func configureHierarchy() {
        view.addSubview(summaryView)
        view.addSubview(activityHeaderView)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(loadingIndicator)

        activityHeaderView.addSubview(activityTitleLabel)
        activityHeaderView.addSubview(activityDividerView)
    }

    private func configureConstraints() {
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        activityHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        activityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityDividerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Summary
            summaryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryView.heightAnchor.constraint(equalToConstant: Layout.summaryHeight),

            // Activity Header (Recent Activity)
            activityHeaderView.topAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: Layout.headerTopPadding),
            activityHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            activityTitleLabel.topAnchor.constraint(equalTo: activityHeaderView.topAnchor),
            activityTitleLabel.leadingAnchor.constraint(equalTo: activityHeaderView.leadingAnchor, constant: Layout.headerHorizontalPadding),
            activityTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: activityHeaderView.trailingAnchor, constant: -Layout.headerHorizontalPadding),

            activityDividerView.topAnchor.constraint(equalTo: activityTitleLabel.bottomAnchor, constant: Layout.headerBottomPadding),
            activityDividerView.leadingAnchor.constraint(equalTo: activityHeaderView.leadingAnchor, constant: Layout.headerHorizontalPadding),
            activityDividerView.trailingAnchor.constraint(equalTo: activityHeaderView.trailingAnchor, constant: -Layout.headerHorizontalPadding),
            activityDividerView.heightAnchor.constraint(equalToConstant: Layout.dividerHeight),
            activityDividerView.bottomAnchor.constraint(equalTo: activityHeaderView.bottomAnchor),

            // Table
            tableView.topAnchor.constraint(equalTo: activityHeaderView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Overlays
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureActivityHeader() {
        activityHeaderView.backgroundColor = .clear
        activityTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            JobApplicationCell.self,
            forCellReuseIdentifier: JobApplicationCell.reuseIdentifier
        )

        // Card görünümünde separator kullanılmaz
        tableView.separatorStyle = .none

        // Listenin üst-alt nefes alması (card spacing daha premium görünür)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)

        // Otomatik yükseklik daha stabil olsun
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 92

        tableView.backgroundColor = .clear
    }

    private func configureOverlays() {
        emptyLabel.isHidden = true
        loadingIndicator.stopAnimating()
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
            setSummaryVisible(false)
            setHeaderVisible(false)
            setTableVisible(false)
            setEmptyVisible(false)
            setLoadingVisible(true)

        case .empty:
            setSummaryVisible(false)
            setHeaderVisible(false)
            setTableVisible(false)
            setLoadingVisible(false)
            setEmptyVisible(true)

        case .loaded(let applications):
            setLoadingVisible(false)
            setEmptyVisible(false)
            setSummaryVisible(true)
            setHeaderVisible(true)
            setTableVisible(true)

            summaryView.update(applications: applications)
            setActivityTitle("Recent Activity")

            tableView.reloadData()

        case .error(let message, let retry):
            setSummaryVisible(false)
            setHeaderVisible(false)
            setTableVisible(false)
            setEmptyVisible(false)
            setLoadingVisible(false)

            presentErrorAlert(message: message, retry: retry)
        }
    }

    // MARK: - UI State Helpers

    private func setSummaryVisible(_ isVisible: Bool) {
        summaryView.isHidden = !isVisible
    }

    private func setHeaderVisible(_ isVisible: Bool) {
        activityHeaderView.isHidden = !isVisible
    }

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
