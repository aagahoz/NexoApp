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

    private let session: SessionProvider

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.session = FirebaseSessionProvider()
    }

    func start() {
        navigationController.viewControllers = []

        if session.isAuthenticated {
            startAuthenticatedFlow()
        } else {
            startGuestFlow()
        }
    }

    private func startGuestFlow() {
        let repository = LocalJobApplicationRepository(
            localDataSource: CoreDataJobApplicationLocalDataSource()
        )

        let coordinator = JobApplicationListCoordinator(
            navigationController: navigationController,
            repository: repository,
            session: session,
            showsLoginButton: true
        )

        childCoordinators = [coordinator]
        coordinator.start()
    }

    private func startAuthenticatedFlow() {
        let repository = RemoteJobApplicationRepository(
            remoteDataSource: FirebaseJobApplicationRemoteDataSource(),
            session: session
        )

        let coordinator = JobApplicationListCoordinator(
            navigationController: navigationController,
            repository: repository,
            session: session,
            showsLoginButton: false
        )

        childCoordinators = [coordinator]
        coordinator.start()
    }
}
