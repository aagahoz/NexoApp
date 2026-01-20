//
//  JobApplicationListViewController.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

@MainActor
final class JobApplicationListViewController: UIViewController {

    private let viewModel: JobApplicationListViewModel
    private var currentState: JobApplicationListViewState = .loading

    // MARK: - UI

    private let headerView = StatusSummaryView()
    private let tableView = UITableView()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No Application found"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    init(viewModel: JobApplicationListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Job Applications"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        setupHeader()
        setupTableView()
        setupOverlays()
        bindViewModel()
        
        Task {
            await viewModel.load()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await viewModel.load()
        }
    }
    
    // MARK: - Setup

    private func setupHeader() {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            JobApplicationCell.self,
            forCellReuseIdentifier: JobApplicationCell.reuseIdentifier
        )

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupOverlays() {
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
    }
    
    @objc private func addTapped() {
        viewModel.onAddTapped?()
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.currentState = state
            self?.render(state: state)
        }
    }

    // MARK: - Render

    private func render(state: JobApplicationListViewState) {
        switch state {

        case .loading:
            tableView.isHidden = true
            emptyLabel.isHidden = true
            headerView.isHidden = true
            loadingIndicator.startAnimating()

        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            headerView.isHidden = true
            emptyLabel.isHidden = false

        case .loaded(let applications):
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true
            headerView.isHidden = false
            tableView.isHidden = false
            tableView.reloadData()
            let summaryViewModel = StatusSummaryViewModel(
                applications: applications
            )
            headerView.update(with: summaryViewModel)

        case .error(let message, let retry):
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = true
            headerView.isHidden = true
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )

            if let retry = retry {
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in retry() })
            }

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
// MARK: - UITableViewDataSource

extension JobApplicationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case let .loaded(jobApplications) = currentState else { return 0 }
        return jobApplications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JobApplicationCell.reuseIdentifier, for: indexPath) as? JobApplicationCell,
              case let .loaded(jobs) = currentState
        else { return UITableViewCell() }

        cell.configure(with: jobs[indexPath.row])
        return cell
    }
    
    
    
}

// MARK: - UITableViewDelegate

extension JobApplicationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectJobApplication(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
      }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            Task {
                await self?.viewModel.deleteJobApplication(at: indexPath.row)
                completion(true)
            }
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
