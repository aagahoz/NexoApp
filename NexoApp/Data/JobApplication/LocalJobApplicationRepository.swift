//
//  LocalJobApplicationRepository.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 19.01.2026.
//

final class LocalJobApplicationRepository: JobApplicationRepository {

    private let localDataSource: JobApplicationLocalDataSource

    init(localDataSource: JobApplicationLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchJobApplications() async throws -> [JobApplication] {
        try await localDataSource.fetchJobApplications()
    }

    func addJobApplication(_ application: JobApplication) async throws {
        try await localDataSource.addJobApplication(application)
    }
}
