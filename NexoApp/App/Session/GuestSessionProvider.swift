//
//  GuestSessionProvider.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 19.01.2026.
//

final class GuestSessionProvider: SessionProvider {
    let isAuthenticated = false
    let userId: String? = nil
    func signOut() throws {
        
    }
}
