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
    private let coreDataManager: ICoreDataManager
    private var cancellables = Set<AnyCancellable>()
    
    internal var locationPublisher: LocationPublisher {
        return locationManager.locationPublisher
    }
    
    init(locationManager: ILocationManager,
         coreDataManager: ICoreDataManager) {
        self.locationManager = locationManager
        self.coreDataManager = coreDataManager
        
        setupBindings()
    }
    
    private func setupBindings() {
        locationPublisher
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] location in
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
