//
//  CoreDataJobApplicationLocalDataSource.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 19.01.2026.
//

import CoreData

final class CoreDataJobApplicationLocalDataSource: JobApplicationLocalDataSource {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func fetchJobApplications() async throws -> [JobApplication] {
        let request: NSFetchRequest<JobApplicationEntity> = JobApplicationEntity.fetchRequest()
        let entities = try context.fetch(request)
        return entities.map { $0.toDomain() }
    }

    func addJobApplication(_ job: JobApplication) async throws {
        let entity = JobApplicationEntity(context: context)
        entity.update(from: job)
        try context.save()
    }

    func saveJobApplications(_ jobs: [JobApplication]) async throws {
        jobs.forEach {
            let entity = JobApplicationEntity(context: context)
            entity.update(from: $0)
        }
        try context.save()
    }
}
