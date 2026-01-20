//
//  FirebaseJobApplicationRemoteDataSource.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 20.01.2026.
//

import Foundation
import FirebaseFirestore

final class FirebaseJobApplicationRemoteDataSource: JobApplicationRemoteDataSource {
    
    private let db = Firestore.firestore()
    private let collection = "jobApplications"
    
    func fetchAll(userId: String) async throws -> [JobApplication] {
        // Modern getDocuments() kullanımı
        let snapshot = try await db.collection(collection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            
            guard
                let title = data["title"] as? String,
                let company = data["company"] as? String,
                let statusRaw = data["status"] as? String,
                let status = JobApplicationStatus(rawValue: statusRaw),
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue(),
                let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
            else {
                return nil
            }
            
            return JobApplication(
                id: UUID(uuidString: doc.documentID) ?? UUID(),
                title: title,
                company: company,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        }
    }
    
    func add(_ job: JobApplication, userId: String) async throws {
        let data: [String: Any] = [
            "title": job.title,
            "company": job.company,
            "status": job.status.rawValue,
            "createdAt": Timestamp(date: job.createdAt),
            "updatedAt": Timestamp(date: job.updatedAt),
            "userId": userId
        ]

        // Modern setData() kullanımı (Continuation gerektirmez)
        try await db.collection(collection)
            .document(job.id.uuidString)
            .setData(data)
    }
    
    func delete(id: UUID, userId: String) async throws {
        // Modern delete() kullanımı
        try await db.collection(collection)
            .document(id.uuidString)
            .delete()
    }
}
