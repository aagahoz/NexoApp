//
//  RemoteJobApplicationRepository.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 20.01.2026.
//

import Foundation

final class RemoteJobApplicationRepository: JobApplicationRepository {

    private let remoteDataSource: JobApplicationRemoteDataSource
    private let session: SessionProvider

    init(
        remoteDataSource: JobApplicationRemoteDataSource,
        session: SessionProvider
    ) {
        self.remoteDataSource = remoteDataSource
        self.session = session
    }

    func fetchJobApplications() async throws -> [JobApplication] {
        guard let userId = session.userId else {
            throw JobApplicationError.unauthorized
        }
        return try await remoteDataSource.fetchAll(userId: userId)
    }

    func addJobApplication(_ application: JobApplication) async throws {
        guard let userId = session.userId else {
            throw JobApplicationError.unauthorized
        }
        try await remoteDataSource.add(application, userId: userId)
    }

    func deleteJobApplication(id: UUID) async throws {
        guard let userId = session.userId else {
            throw JobApplicationError.unauthorized
        }
        try await remoteDataSource.delete(id: id, userId: userId)
    }
}
