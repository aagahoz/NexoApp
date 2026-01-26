//
//  LoginCoordinator.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 21.01.2026.
//

import UIKit

final class LoginCoordinator: NSObject, Coordinator {

    var navigationController: UINavigationController
    private let authService: AuthService

    // Parent coordinator burayı set edecek
    var onFinish: (() -> Void)?

    // Present ettiğimiz nav’ı tutalım ki delegate bağlayabilelim
    private var presentedNavigationController: UINavigationController?

    init(
        navigationController: UINavigationController,
        authService: AuthService
    ) {
        self.navigationController = navigationController
        self.authService = authService
    }

    func start() {
        let viewModel = LoginViewModel(authService: authService)
        let viewController = LoginViewController(viewModel: viewModel)

        viewModel.onSuccess = { [weak self] in
            self?.finishAndDismiss()
        }

        viewModel.onError = { [weak viewController] error in
            viewController?.showError(error)
        }

        let nav = UINavigationController(rootViewController: viewController)

        // Kullanıcı swipe-down ile kapatırsa da finish çalışsın
        nav.presentationController?.delegate = self
        presentedNavigationController = nav

        navigationController.present(nav, animated: true)
    }

    private func finishAndDismiss() {
        // Dismiss tamamlanınca parent temizlesin
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onFinish?()
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension LoginCoordinator: UIAdaptivePresentationControllerDelegate {

    // Kullanıcı modalı interaktif olarak kapatınca (swipe down)
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onFinish?()
    }
}
