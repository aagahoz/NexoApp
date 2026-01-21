//
//  Job.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import Foundation

struct JobApplication {
    let id: UUID
    let title: String
    let company: String
    let status: JobApplicationStatus
    let createdAt: Date
    let updatedAt: Date
}
