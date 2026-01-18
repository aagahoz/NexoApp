//
//  JobApplicationListCoordinator.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 12.01.2026.
//

import UIKit

final class JobApplicationListCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = JobApplicationListViewModel(repository: MockJobApplicationRepository())
        let jobApplicationListVC = JobApplicationListViewController(viewModel: viewModel)
        
        // Coordinator’ı viewModel’a bağlayarak seçilen job’u handle edeceğiz
        viewModel.onJobApplicationSelected = { [weak self] jobApplication in
            self?.showJobApplicationDetail(jobApplication: jobApplication)
        }

        navigationController.pushViewController(jobApplicationListVC, animated: true)
    }

    private func showJobApplicationDetail(jobApplication: JobApplication) {
        let detailVC = JobApplicationDetailViewController(jobApplication: jobApplication)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
