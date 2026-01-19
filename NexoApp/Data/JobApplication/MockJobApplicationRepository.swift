//
//  MockJobApplicationRepository.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import Foundation

actor MockJobApplicationRepository: JobApplicationRepository {
    
    private var applications: [JobApplication] = [
        JobApplication(id: UUID(), title: "iOS Developer", company: "Nexo", status: .applied),
        JobApplication(id: UUID(), title: "Junior iOS Developer", company: "Startup X", status: .reviewing)
    ]
    
    func fetchJobApplications() async throws -> [JobApplication] {
//        throw JobApplicationError.network
        
//        try? await Task.sleep(nanoseconds: 1_000_000_000)

        return applications
    }
    
    func addJobApplication(_ application: JobApplication) async throws {
        applications.append(application)
    }
}
