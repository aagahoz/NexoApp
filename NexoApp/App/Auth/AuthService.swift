//
//  AuthService.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 21.01.2026.
//

import Foundation

protocol AuthService {
    func signInWithApple() async throws
    func signOut() throws
}
