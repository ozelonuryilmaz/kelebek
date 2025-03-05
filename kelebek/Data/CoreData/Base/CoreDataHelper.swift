//
//  CoreDataHelper.swift
//  kelebek
//
//  Created by Onur Yılmaz on 5.03.2025.
//

import Foundation
import CoreData

final class CoreDataHelper {

    static let shared = CoreDataHelper() // Opsiyonel: Test için bağımsız hale getirebiliriz.
    
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Kelebekapp")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Core Data yüklenirken hata oluştu: \(error.localizedDescription)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("Core Data kaydetme hatası: \(error.localizedDescription)")
        }
    }
}

// MARK: - Managed Context with Merge Policy
extension CoreDataHelper {

    func getManagedContextWithMergePolicy() -> NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return context
    }
}
