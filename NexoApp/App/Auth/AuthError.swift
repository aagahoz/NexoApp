//
//  AuthError.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 21.01.2026.
//

import Foundation

enum AuthError: Error {
    case userCancelled
    case network
    case configuration
    case unauthorized
    case unknown
}

extension AuthError {
    var userMessage: String {
        switch self {
        case .userCancelled:
            return "Login cancelled"
        case .network:
            return "Network connection failed"
        case .configuration:
            return "Login configuration error"
        case .unauthorized:
            return "Unauthorized"
        case .unknown:
            return "Something went wrong"
        }
    }
}
