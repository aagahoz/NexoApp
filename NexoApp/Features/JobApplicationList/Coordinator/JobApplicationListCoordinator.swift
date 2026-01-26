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
    private let showsLoginButton: Bool
    private let authService: AuthService

    private var childCoordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController,
        repository: JobApplicationRepository,
        authService: AuthService,
        showsLoginButton: Bool
    ) {
        self.navigationController = navigationController
        self.repository = repository
        self.authService = authService
        self.showsLoginButton = showsLoginButton
    }

    func start() {
        let viewModel = JobApplicationListViewModel(repository: repository)

        let jobApplicationListVC = JobApplicationListViewController(
            viewModel: viewModel,
            showsLoginButton: showsLoginButton
        )

        jobApplicationListVC.onLoginTapped = { [weak self] in
            self?.showLogin()
        }

        jobApplicationListVC.onLogoutTapped = { [weak self] in
            self?.handleLogout()
        }

        viewModel.onJobApplicationSelected = { [weak self] jobApplication in
            self?.showJobApplicationDetail(jobApplication: jobApplication)
        }

        viewModel.onAddTapped = { [weak self] in
            self?.showAddJobApplication()
        }

        navigationController.pushViewController(jobApplicationListVC, animated: true)
    }

    private func showAddJobApplication() {
        let viewModel = AddJobApplicationViewModel(repository: repository)
        let vc = AddJobApplicationViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    private func showJobApplicationDetail(jobApplication: JobApplication) {
        let detailVC = JobApplicationDetailViewController(jobApplication: jobApplication)
        navigationController.pushViewController(detailVC, animated: true)
    }

    private func showLogin() {
        let coordinator = LoginCoordinator(
            navigationController: navigationController,
            authService: authService
        )

        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.removeChild(coordinator)
        }

        addChild(coordinator)
        coordinator.start()
    }

    private func handleLogout() {
        do {
            try authService.signOut()
        } catch {
            print("Logout failed: \(error)")
        }
    }

    // MARK: - Child coordinator management

    private func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    private func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator as AnyObject }
    }
}
