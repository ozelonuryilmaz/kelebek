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
    
    private let locationService: ILocationManager
    private let coreDataManager: CoreDataManager
    private var cancellables = Set<AnyCancellable>()
    private var lastLocation: CLLocation? = nil
    
    internal var locationPublisher: LocationPublisher {
        return locationService.locationPublisher
    }
    
    init(locationService: ILocationManager,
         coreDataManager: CoreDataManager,
         cancellables: Set<AnyCancellable> = Set<AnyCancellable>(),
         lastLocation: CLLocation? = nil) {
        self.locationService = locationService
        self.coreDataManager = coreDataManager
        self.cancellables = cancellables
        self.lastLocation = lastLocation
        
        setupBindings()
    }
    
    private func setupBindings() {
        locationPublisher
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] location in
                self?.lastLocation = location
                self?.saveLocation(location)
            }
            .store(in: &cancellables)
    }
}

// MARK: LocationManager
extension LocationUseCase {
    
    func requestLocationPermission() {
        locationService.requestPermission()
    }
    
    func startTracking() {
        locationService.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationService.stopUpdatingLocation()
    }
}

// MARK: CoreData
extension LocationUseCase {
   
    func saveLocation(_ location : CLLocation) {
        // TODO: CoreData eklendiğinde konumu kaydet
    }
    
    func getLastSavedLocation() -> CLLocation? {
        // TODO: CoreData eklendiğinde son konumu getir
        return nil
    }
    
    func clearAllLocations() {
        // TODO: CoreData eklendiğinde tüm kayıtları sil
    }
}
