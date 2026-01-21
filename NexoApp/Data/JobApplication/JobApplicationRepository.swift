//
//  JobApplicationRepository.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import Foundation

protocol JobApplicationRepository {
    func fetchJobApplications() async throws -> [JobApplication]
    func addJobApplication(_ application: JobApplication) async throws
    func deleteJobApplication(id: UUID) async throws
}
