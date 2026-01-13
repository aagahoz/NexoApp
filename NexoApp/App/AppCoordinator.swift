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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showJobList()
    }

    private func showJobList() {
        let jobListCoordinator = JobListCoordinator(
            navigationController: navigationController
        )

        childCoordinators.append(jobListCoordinator)
        jobListCoordinator.start()
    }
}
