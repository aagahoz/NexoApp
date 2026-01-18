//
//  MockJobApplicationRepository.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

final class MockJobApplicationRepository: JobApplicationRepository {
    
    func fetchJobApplications() async throws -> [JobApplication] {
//        throw JobApplicationError.network
        
//        try? await Task.sleep(nanoseconds: 3_000_000_000)

        return [
            JobApplication(id: 1, title: "iOS Developer", company: "Nexo", status: .applied),
            JobApplication(id: 2, title: "Junior iOS Developer", company: "Startup X", status: .reviewing)
        ]
    }
}
