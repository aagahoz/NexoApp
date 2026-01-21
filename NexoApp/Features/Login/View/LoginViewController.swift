//
//  LoginViewController.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 21.01.2026.
//

import UIKit
import AuthenticationServices

final class LoginViewController: UIViewController {

    private let viewModel: LoginViewModel
    private let signInButton = ASAuthorizationAppleIDButton()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Sign In"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupButton()
    }

    private func setupButton() {
        signInButton.addTarget(
            self,
            action: #selector(loginTapped),
            for: .touchUpInside
        )

        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 44),
            signInButton.widthAnchor.constraint(equalToConstant: 260)
        ])
    }

    @objc private func loginTapped() {
        Task {
            await viewModel.loginWithApple()
        }
    }

    func showError(_ error: AuthError) {
        let alert = UIAlertController(
            title: "Login Failed",
            message: error.userMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
