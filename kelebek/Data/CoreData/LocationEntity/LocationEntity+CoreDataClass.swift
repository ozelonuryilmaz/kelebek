//
//  LocationEntity+CoreDataClass.swift
//  kelebek
//
//  Created by Onur Yılmaz on 5.03.2025.
//

import Foundation
import CoreData

public class LocationEntity: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationEntity> {
        return NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
    }

    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var date: Date
}

extension LocationEntity : Identifiable {

}

extension LocationEntity {

    func toModel() -> LocationModel {
        return LocationModel(location: LMLocation(latitude: self.lat, longitude: self.lon))
    }
}
