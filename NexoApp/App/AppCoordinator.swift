//
//  AppCoordinator.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 14.01.2026.
//

import UIKit

final class AppCoordinator: Coordinator {

    var navigationController: UINavigationController
    private var childCoordinators: [Coordinator] = []
    
    private let jobapplicationRepository: JobApplicationRepository

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.jobapplicationRepository = MockJobApplicationRepository()
    }

    func start() {
        showJobApplicationList()
    }

    private func showJobApplicationList() {
        let jobApplicationListCoordinator = JobApplicationListCoordinator(
            navigationController: navigationController,
            repository: jobapplicationRepository
        )

        childCoordinators.append(jobApplicationListCoordinator)
        jobApplicationListCoordinator.start()
    }
}
                             
