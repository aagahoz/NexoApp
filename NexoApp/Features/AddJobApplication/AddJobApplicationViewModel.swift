//
//  AddJobApplicationViewModel.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 18.01.2026.
//

import Foundation

@MainActor
final class AddJobApplicationViewModel {
    
    private let repository: JobApplicationRepository
    
    private(set) var state: AddJobApplicationViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((AddJobApplicationViewState) -> Void)?
    
    init(repository: JobApplicationRepository) {
        self.repository = repository
    }
    
    func save(title: String, company: String, status: JobApplicationStatus) async {
        
        state = .saving
        
        let now = Date()
        
        let newApplication = JobApplication(id: UUID(), title: title, company: company, status: status, createdAt: now, updatedAt: now)
        
        do {
            try await repository.addJobApplication(newApplication)
            state = .success
        } catch {
            state = .error(message: "Could not save application")
        }
        
    }
}
