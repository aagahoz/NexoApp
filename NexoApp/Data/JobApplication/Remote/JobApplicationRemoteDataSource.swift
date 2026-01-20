//
//  JobApplicationRemoteDataSource.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 19.01.2026.
//

import Foundation

protocol JobApplicationRemoteDataSource {
    func fetchAll(userId: String) async throws -> [JobApplication]
    func add(_ job: JobApplication, userId: String) async throws
    func delete(id: UUID, userId: String) async throws
}
