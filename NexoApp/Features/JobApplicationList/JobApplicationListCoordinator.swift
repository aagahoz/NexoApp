//
//  JobApplicationListCoordinator.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 12.01.2026.
//

import UIKit

final class JobApplicationListCoordinator: Coordinator {

    var navigationController: UINavigationController
    private let repository: JobApplicationRepository

    init(
        navigationController: UINavigationController,
        repository: JobApplicationRepository
    ) {
        self.navigationController = navigationController
        self.repository = repository
    }

    func start() {
        let viewModel = JobApplicationListViewModel(
            repository: repository
        )
        let jobApplicationListVC = JobApplicationListViewController(
            viewModel: viewModel
        )
        
        viewModel.onJobApplicationSelected = { [weak self] jobApplication in
            self?.showJobApplicationDetail(jobApplication: jobApplication)
        }
        
        viewModel.onAddTapped = { [weak self] in
            self?.showAddJobApplication()
        }

        navigationController.pushViewController(jobApplicationListVC, animated: true)
    }
    
    func showAddJobApplication() {
        let viewModel = AddJobApplicationViewModel(repository: repository)
        let vc = AddJobApplicationViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    private func showJobApplicationDetail(jobApplication: JobApplication) {
        let detailVC = JobApplicationDetailViewController(jobApplication: jobApplication)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
