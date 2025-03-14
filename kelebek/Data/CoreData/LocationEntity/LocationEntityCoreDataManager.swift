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
    func getAllRoutes() -> [[LMLocationCoordinate2D]]
    
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
    
    func getAllRoutes() -> [[LMLocationCoordinate2D]] {
        let fetchRequest: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            let locations = try managedContext.fetch(fetchRequest)
            guard locations.count > 1 else { return [] }

            var routes: [[LMLocationCoordinate2D]] = []
            var currentRoute: [LMLocationCoordinate2D] = []
            var previousLocation: LMLocation?

            for location in locations {
                let currentCoordinate = LMLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
                let currentLocation = LMLocation(latitude: location.lat, longitude: location.lon)

                if let lastLocation = previousLocation {
                    let distance = lastLocation.distance(from: currentLocation)
                    if distance > Constants.MapDistance.max {
                        if !currentRoute.isEmpty {
                            routes.append(currentRoute)
                        }
                        currentRoute = []
                    }
                }

                currentRoute.append(currentCoordinate)
                previousLocation = currentLocation
            }

            if !currentRoute.isEmpty {
                routes.append(currentRoute)
            }

            return routes
        } catch {
            print("Core Data Fetch Error: \(error)")
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
