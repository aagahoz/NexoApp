//
//  JobApplicationRepository.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

protocol JobApplicationRepository {
    func fetchJobApplications() async throws -> [JobApplication]
    func addJobApplication(_ application: JobApplication) async throws
}
