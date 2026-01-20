//
//  SessionProvider.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 19.01.2026.
//

protocol SessionProvider {
    var isAuthenticated: Bool { get }
    var userId: String? { get }
}
