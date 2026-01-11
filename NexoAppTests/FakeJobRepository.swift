//
//  FakeJobRepository.swift
//  NexoAppTests
//
//  Created by Agah Ozdemir on 11.01.2026.
//

@testable import NexoApp

import Foundation

final class FakeJobRepository: JobRepository {
    
    let jobsToReturn: [Job]
    
    init(jobsToReturn: [Job]) {
        self.jobsToReturn = jobsToReturn
    }
    
    func fetchJobs() -> [Job] {
        jobsToReturn
    }
}
