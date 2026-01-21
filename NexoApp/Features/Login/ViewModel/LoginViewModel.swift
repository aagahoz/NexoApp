//
//  LoginViewModel.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 21.01.2026.
//

import Foundation

@MainActor
final class LoginViewModel {

    private let authService: AuthService

    var onSuccess: (() -> Void)?
    var onError: ((AuthError) -> Void)?

    init(authService: AuthService) {
        self.authService = authService
    }

    func loginWithApple() async {
        do {
            try await authService.signInWithApple()
            onSuccess?()
        } catch let error as AuthError {
            onError?(error)
        } catch {
            onError?(.unknown)
        }
    }
}
