//
//  MockJobApplicationRepository.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import Foundation

actor MockJobApplicationRepository: JobApplicationRepository {
    func deleteJobApplication(id: UUID) async throws {
        print("benim olmamam lazim")
    }
    
        
    private var applications: [JobApplication] = [
        JobApplication(id: UUID(), title: "iOS Developer", company: "Nexo", status: .applied, createdAt: Date(), updatedAt: Date()),
        JobApplication(id: UUID(), title: "Junior iOS Developer", company: "Startup X", status: .reviewing, createdAt: Date(), updatedAt: Date())
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
