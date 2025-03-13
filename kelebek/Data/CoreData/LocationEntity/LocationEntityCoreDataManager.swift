//
//  LocationEntityCoreDataManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 5.03.2025.
//

import Foundation
import CoreData

protocol ILocationEntityCoreDataManager: AnyObject {

    func getAllLocationsEntity() -> [LocationModel]
    
    @discardableResult
    func insertLocationEntity(_ location: LMLocation) -> Bool
    
    @discardableResult
    func clearAllLocationEntity() -> Bool
}

class LocationEntityCoreDataManager: BaseCoreDataManager<LocationEntity>, ILocationEntityCoreDataManager {

    func getAllLocationsEntity() -> [LocationModel] {
        let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            return try managedContext.fetch(fetchRequest).map { $0.toModel() }
        } catch {
            return []
        }
    }

    @discardableResult
    func insertLocationEntity(_ location: LMLocation) -> Bool {
        let newLocationEntity = LocationEntity(context: managedContext)
        newLocationEntity.lat = location.coordinate.latitude
        newLocationEntity.lon = location.coordinate.longitude
        newLocationEntity.date = Date()
        
        return saveContext()
    }
    
    @discardableResult
    func clearAllLocationEntity() -> Bool {
        return deleteAllObjectsWithBatchRequest()
    }
}
