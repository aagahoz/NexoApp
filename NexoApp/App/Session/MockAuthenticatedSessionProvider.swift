//
//  MockAuthenticatedSessionProvider.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 20.01.2026.
//

import Foundation

final class MockAuthenticatedSessionProvider: SessionProvider {
    let isAuthenticated = true
    let userId: String? = "TEST_USER_ID2"
    func signOut() throws {
        
    }
}
