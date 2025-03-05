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
    func requestLocationPermission()
    func startTracking()
    func stopTracking()
    func saveLocation(_ location : CLLocation)
    func getLastSavedLocation() -> CLLocation?
    func clearAllLocations()
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
        
        setupBindings()
    }
    
    private func setupBindings() {
        locationPublisher
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] location in
                self?.clearAllLocations()
                self?.saveLocation(location)
            }
            .store(in: &cancellables)
    }
}

// MARK: LocationManager
extension LocationUseCase {
    
    func requestLocationPermission() {
        locationManager.requestPermission()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: CoreData
extension LocationUseCase {
   
    func saveLocation(_ location : CLLocation) {
        locationEntityCoreDataManager.insertLocationEntity(lat: location.coordinate.latitude,
                                                           lon: location.coordinate.longitude)
    }
    
    func getLastSavedLocation() -> CLLocation? {
        guard let location = locationEntityCoreDataManager.getLastLocationEntity() else { return nil }
        return CLLocation(latitude: location.lat, longitude: location.lon)
    }
    
    func clearAllLocations() {
        locationEntityCoreDataManager.clearAllLocationEntity()
    }
}
