//
//  JobListCoordinator.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 12.01.2026.
//

import UIKit

final class JobListCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = JobListViewModel(repository: MockJobRepository())
        let jobListVC = JobListViewController(viewModel: viewModel)
        
        // Coordinator’ı viewModel’a bağlayarak seçilen job’u handle edeceğiz
        viewModel.onJobSelected = { [weak self] job in
            self?.showJobDetail(job: job)
        }

        navigationController.pushViewController(jobListVC, animated: true)
    }

    private func showJobDetail(job: Job) {
        let detailVC = JobDetailViewController(job: job)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
