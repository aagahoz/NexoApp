//
//  JobApplicationEntity+Mapping.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 19.01.2026.
//

import CoreData

extension JobApplicationEntity {
    
    func toDomain() -> JobApplication {
        JobApplication(
            id: id!,
            title: title ?? "",
            company: company ?? "",
            status: JobApplicationStatus(rawValue: statusRawValue ?? "") ?? .notApplied,
            createdAt: createdAt ?? updatedAt ?? Date(),
            updatedAt: updatedAt ?? createdAt ?? Date()
        )
    }
    
    func update(from domain: JobApplication) {
        id = domain.id
        title = domain.title
        company = domain.company
        statusRawValue = domain.status.rawValue
        createdAt = domain.createdAt
        updatedAt = domain.updatedAt
    }
}
