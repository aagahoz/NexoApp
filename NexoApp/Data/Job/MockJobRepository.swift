//
//  MockJobRepository.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

final class MockJobRepository: JobRepository {
    
    func fetchJobs() async throws -> [Job] {
//        throw JobError.network
        
//        try? await Task.sleep(nanoseconds: 3_000_000_000)

        return [
            Job(id: 1, title: "iOS Developer", company: "Nexo"),
            Job(id: 2, title: "Junior iOS Developer", company: "Startup X")
        ]
    }
}
