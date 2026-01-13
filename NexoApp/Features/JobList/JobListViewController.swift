//
//  JobListViewController.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

@MainActor
final class JobListViewController: UIViewController {

    private let viewModel: JobListViewModel

    private var currentState: JobListViewState = .loading

    private let tableView = UITableView()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No jobs found"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(viewModel: JobListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Jobs"

        setupTableView()
        setupSubviews()
        bindViewModel()

        Task { await viewModel.load() }
    }

    private func setupSubviews() {
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JobCell.self, forCellReuseIdentifier: JobCell.reuseIdentifier)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.currentState = state
            self?.render(state: state)
        }
    }

    private func render(state: JobListViewState) {
        switch state {
        case .loading:
            tableView.isHidden = true
            emptyLabel.isHidden = true
            loadingIndicator.startAnimating()

        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = false

        case .loaded:
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()

        case .error(let message, let retry):
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = true

            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            if let retry = retry {
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in retry() })
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension JobListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case let .loaded(jobs) = currentState else { return 0 }
        return jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JobCell.reuseIdentifier, for: indexPath) as? JobCell,
              case let .loaded(jobs) = currentState
        else { return UITableViewCell() }

        cell.configure(with: jobs[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension JobListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          viewModel.didSelectJob(at: indexPath.row)
      }
}
