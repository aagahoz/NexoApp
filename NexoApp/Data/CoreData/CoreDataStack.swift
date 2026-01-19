//
//  CoreDataStack.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 19.01.2026.
//

import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "NexoApp")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data load error: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
}
