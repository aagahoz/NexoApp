//
//  FakeJobRepository.swift
//  NexoAppTests
//
//  Created by Agah Ozdemir on 11.01.2026.
//

@testable import NexoApp

/// Testlerde retry senaryosunu simüle etmek için kullanılan repository.
/// İlk fetch hata döndürür, sonraki fetch başarılı veri döndürür.
final class FakeJobRepository: JobRepository {

    private var fetchCount = 0
    let jobsToReturn: [Job]
    let errorToThrow: JobError?

    init(jobsToReturn: [Job], errorToThrow: JobError? = nil) {
        self.jobsToReturn = jobsToReturn
        self.errorToThrow = errorToThrow
    }

    func fetchJobs() async throws -> [Job] {
        fetchCount += 1
        if fetchCount == 1, let error = errorToThrow {
            throw error
        }
        return jobsToReturn
    }
}
