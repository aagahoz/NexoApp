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
    private let authService: AuthService

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.session = FirebaseSessionProvider()
        self.authService = FirebaseAuthService()
    }

    func start() {
        navigationController.setViewControllers([], animated: false)

        let repository: JobApplicationRepository
        let showsLoginButton: Bool

        if session.isAuthenticated {
            repository = RemoteJobApplicationRepository(
                remoteDataSource: FirebaseJobApplicationRemoteDataSource(),
                session: session
            )
            showsLoginButton = false
        } else {
            repository = LocalJobApplicationRepository(
                localDataSource: CoreDataJobApplicationLocalDataSource()
            )
            showsLoginButton = true
        }

        let coordinator = JobApplicationListCoordinator(
            navigationController: navigationController,
            repository: repository,
            authService: authService,
            showsLoginButton: showsLoginButton
        )

        childCoordinators = [coordinator]
        coordinator.start()
    }
}
