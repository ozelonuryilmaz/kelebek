//
//  LocationUseCase.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation
import CoreLocation
import Combine

protocol ILocationUseCase {
    var locationPublisher: LocationPublisher { get }
    
    // LocationManager
    func requestLocationPermission(completion: @escaping (Bool) -> Void)
    func startTracking()
    func stopTracking()
    func getLastKnownLocation() -> CLLocation?
    func clearLastKnownLocation()
    
    // CoreData
    func saveFixedLocation(_ location : CLLocation)
    func getLastSavedFixedLocation() -> CLLocation?
    func clearAllFixedLocations()
}

final class LocationUseCase: ILocationUseCase {
    
    private let locationManager: ILocationManager
    private let locationEntityCoreDataManager: ILocationEntityCoreDataManager
    private var cancellables = Set<AnyCancellable>()

    internal var locationPublisher: LocationPublisher {
        return locationManager.locationPublisher
    }
    
    init(locationManager: ILocationManager,
         locationEntityCoreDataManager: ILocationEntityCoreDataManager) {
        self.locationManager = locationManager
        self.locationEntityCoreDataManager = locationEntityCoreDataManager
    }
}

// MARK: LocationManager
extension LocationUseCase {
    
    func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        locationManager.requestPermission(completion: completion)
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func getLastKnownLocation() -> CLLocation? {
        return locationManager.lastSentLocation
    }
    
    func clearLastKnownLocation() {
        return locationManager.clearLastKnownLocation()
    }
}

// MARK: CoreData
extension LocationUseCase {
   
    func saveFixedLocation(_ location : CLLocation) {
        locationEntityCoreDataManager.insertLocationEntity(
            model: LocationEntityModel(lat: location.coordinate.latitude,
                                       lon: location.coordinate.longitude)
        )
    }
    
    func getLastSavedFixedLocation() -> CLLocation? {
        guard let location = locationEntityCoreDataManager.getLastLocationEntity() else { return nil }
        return CLLocation(latitude: location.lat, longitude: location.lon)
    }
    
    func clearAllFixedLocations() {
        locationEntityCoreDataManager.clearAllLocationEntity()
    }
}
