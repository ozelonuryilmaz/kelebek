//
//  CoreDataHelper.swift
//  kelebek
//
//  Created by Onur Yılmaz on 5.03.2025.
//

import Foundation
import CoreData

final class CoreDataHelper {

    static let shared = CoreDataHelper()

    private init() { }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Kelebekapp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = CoreDataHelper.shared.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataHelper {

    func getCoreDataManagedContextWithMergePolicy() -> NSManagedObjectContext {
        let managedContext = CoreDataHelper.shared.persistentContainer.viewContext
        managedContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        return managedContext
    }
}
