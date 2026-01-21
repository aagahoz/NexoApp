//
//  FirebaseSessionProvider.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 20.01.2026.
//

import FirebaseAuth

final class FirebaseSessionProvider: SessionProvider {
    
    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
