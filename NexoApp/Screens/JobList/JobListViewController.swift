//
//  JobListViewController.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

final class JobListViewController: UIViewController {
    
    private let viewModel = JobListViewModel(
        repository: MockJobRepository()
    )
    
//    private let statusLabel = UILabel()
    private let tableView = UITableView()
    private var jobs: [Job] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Jobs"
        
        setupTableView()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(
            JobCell.self,
            forCellReuseIdentifier: JobCell.reuseIdentifier
        )
            
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
            self?.render(state: state)
        }
    }
    
    private func render(state: JobListViewState) {
        switch state {
        case .loading:
            break
        case .empty:
            jobs = []
            tableView.reloadData()
        case .loaded(let jobs):
            self.jobs = jobs
            tableView.reloadData()
        case .error:
            break
        }
    }
}

extension JobListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: JobCell.reuseIdentifier,
                for: indexPath
            ) as? JobCell
        else {
            return UITableViewCell()
        }
        
        let job = jobs[indexPath.row]
        cell.configure(with: job)
        return cell
    }
}

