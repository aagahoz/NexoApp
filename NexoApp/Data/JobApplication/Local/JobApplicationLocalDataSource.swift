//
//  JobApplicationLocalDataSource.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 19.01.2026.
//

import Foundation

protocol JobApplicationLocalDataSource {
    func fetchJobApplications() async throws -> [JobApplication]
    func addJobApplication(_ job: JobApplication) async throws
    func saveJobApplications(_ jobs: [JobApplication]) async throws
    func deleteJobApplication(id: UUID) async throws
}
