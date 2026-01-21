//
//  LoginCoordinator.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 21.01.2026.
//

import UIKit

final class LoginCoordinator: Coordinator {

    var navigationController: UINavigationController
    private let authService: AuthService

    init(
        navigationController: UINavigationController,
        authService: AuthService
    ) {
        self.navigationController = navigationController
        self.authService = authService
    }

    func start() {
        let viewModel = LoginViewModel(authService: authService)

        let viewController = LoginViewController(
            viewModel: viewModel
        )

        viewModel.onSuccess = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }

        viewModel.onError = { [weak viewController] error in
            viewController?.showError(error)
        }

        let nav = UINavigationController(rootViewController: viewController)
        navigationController.present(nav, animated: true)
    }
}
