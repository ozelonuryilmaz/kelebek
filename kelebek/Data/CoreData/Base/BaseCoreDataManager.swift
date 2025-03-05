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

    // MARK: - Fetch All Objects
    @discardableResult
    internal func getAllObjects(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T]? {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        do {
            return try managedContext.fetch(fetchRequest)
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Delete Objects with Predicate
    @discardableResult
    internal func deleteObjects(with predicate: NSPredicate) -> Bool {
        return performDelete(fetchRequest: NSFetchRequest(entityName: entityName), predicate: predicate)
    }

    // MARK: - Delete All Objects
    @discardableResult
    internal func deleteAllObjects() -> Bool {
        return performDelete(fetchRequest: NSFetchRequest(entityName: entityName), predicate: nil)
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

    // MARK: - Helper Delete Function
    private func performDelete(fetchRequest: NSFetchRequest<T>, predicate: NSPredicate?) -> Bool {
        fetchRequest.predicate = predicate

        do {
            let objects = try managedContext.fetch(fetchRequest)
            objects.forEach { managedContext.delete($0) }
            return saveContext()
        } catch {
            print("Delete error: \(error.localizedDescription)")
            return false
        }
    }
}
