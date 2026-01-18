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
        showJobApplicationList()
    }

    private func showJobApplicationList() {
        let jobApplicationListCoordinator = JobApplicationListCoordinator(
            navigationController: navigationController
        )

        childCoordinators.append(jobApplicationListCoordinator)
        jobApplicationListCoordinator.start()
    }
}
