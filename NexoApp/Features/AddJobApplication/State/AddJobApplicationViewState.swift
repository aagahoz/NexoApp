//
//  AddJobApplicationViewState.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 18.01.2026.
//

enum AddJobApplicationViewState {
    case idle
    case saving
    case success
    case error(message: String)
}
