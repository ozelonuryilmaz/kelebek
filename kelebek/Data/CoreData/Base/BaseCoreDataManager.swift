//
//  CoreDataManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import CoreData

class BaseCoreDataManager<T: NSManagedObject> {
    
    internal let managedContext: NSManagedObjectContext

    internal var entityName: String {
        return String(describing: T.self)
    }

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }

    // MARK: - Delete All Using Batch Request
    @discardableResult
    internal func deleteAllObjectsWithBatchRequest() -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
            return true
        } catch {
            print("Batch delete error: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Save Context
    @discardableResult
    internal func saveContext() -> Bool {
        guard managedContext.hasChanges else { return true }

        do {
            try managedContext.save()
            return true
        } catch {
            print("Save context error: \(error.localizedDescription)")
            return false
        }
    }
}
