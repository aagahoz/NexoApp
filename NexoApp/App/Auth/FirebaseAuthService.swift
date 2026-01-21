//
//  FirebaseAuthService.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 21.01.2026.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

final class FirebaseAuthService: NSObject, AuthService {

    private var currentNonce: String?
    private var continuation: CheckedContinuation<Void, Error>?

    func signInWithApple() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            startAppleSignIn()
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}

extension FirebaseAuthService: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let appleIDCredential =
                authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = appleIDCredential.identityToken,
            let tokenString =
                String(data: identityToken, encoding: .utf8),
            let nonce = currentNonce
        else {
            continuation?.resume(throwing: AuthError.unknown)
            continuation = nil
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: tokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        signInToFirebase(with: credential)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: AuthError.userCancelled)
        continuation = nil
    }
}

extension FirebaseAuthService:
    ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .keyWindow ?? UIWindow()
    }
}

private extension FirebaseAuthService {

    func startAppleSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(
            authorizationRequests: [request]
        )
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

private extension FirebaseAuthService {

    func signInToFirebase(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] _, error in
            guard let self else { return }

            if let error {
                self.continuation?.resume(
                    throwing: self.mapFirebaseError(error)
                )
                self.continuation = nil
                return
            }

            // 🔑 Firebase session artık aktif
            self.continuation?.resume()
            self.continuation = nil
        }
    }
}

private extension FirebaseAuthService {

    func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError

        if nsError.domain == AuthErrorDomain {
            return .unauthorized
        }

        return .unknown
    }
}

private func randomNonceString(length: Int = 32) -> String {
    let charset =
    "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms: [UInt8] = (0..<16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(
                kSecRandomDefault, 1, &random
            )
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce.")
            }
            return random
        }

        randoms.forEach { random in
            if remainingLength == 0 { return }
            if random < charset.count {
                result.append(
                    charset[charset.index(
                        charset.startIndex,
                        offsetBy: Int(random)
                    )]
                )
                remainingLength -= 1
            }
        }
    }

    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map {
        String(format: "%02x", $0)
    }.joined()
}
