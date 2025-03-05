//
//  LocationEntityCoreDataManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 5.03.2025.
//

import Foundation
import CoreData

protocol ILocationEntityCoreDataManager: AnyObject {

    func getLastLocationEntity() -> LocationEntity?
    
    @discardableResult
    func insertLocationEntity(lat: Double, lon: Double) -> Bool
    
    @discardableResult
    func clearAllLocationEntity() -> Bool
}

class LocationEntityCoreDataManager: BaseCoreDataManager<LocationEntity>, ILocationEntityCoreDataManager {

    func getLastLocationEntity() -> LocationEntity? {
        let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            return try managedContext.fetch(fetchRequest).first
        } catch {
            return nil
        }
    }

    @discardableResult
    func insertLocationEntity(lat: Double, lon: Double) -> Bool {
        let newLocationEntity = LocationEntity(context: managedContext)
        newLocationEntity.lat = lat
        newLocationEntity.lon = lon
        newLocationEntity.date = Date()
        
        return saveContext()
    }
    
    @discardableResult
    func clearAllLocationEntity() -> Bool {
        return deleteAllObjectsWithBatchRequest()
    }
}
