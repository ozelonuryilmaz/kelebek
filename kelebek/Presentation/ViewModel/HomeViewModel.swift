//
//  HomeViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation

protocol IHomeViewModel: LMLocationManagerDelegate {
    var isTrackingActive: Bool { get }
    
    // LocationManager
    func requestLocationPermission()
    func startTracking()
    func stopTracking()
    
    // CoreDataManager
    func updateFixedLocation(_ location: LMLocation)
    func clearAllFixedLocations()
}

final class HomeViewModel: BaseViewModel, IHomeViewModel {

    private let locationManager: ILocationManager
    private let locationCoreDataManager: ILocationEntityCoreDataManager
    private(set) var isTrackingActive: Bool = false

    init(locationManager: ILocationManager,
         locationCoreDataManager: ILocationEntityCoreDataManager) {
        self.locationManager = locationManager
        self.locationCoreDataManager = locationCoreDataManager
        super.init()
        self.locationManager.delegate = self
    }
}

// MARK: LocationManager
extension HomeViewModel {
    
    func requestLocationPermission() {
        locationManager.requestPermission()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        isTrackingActive = true
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTrackingActive = false
    }
}

// MARK: CoreDataManager
extension HomeViewModel {
    
    func updateFixedLocation(_ location: LMLocation) {
        locationCoreDataManager.insertLocationEntity(location)
    }
    
    func clearAllFixedLocations() {
        locationCoreDataManager.clearAllLocationEntity()
    }
}

// MARK: LMLocationManagerDelegate
extension HomeViewModel {
    
    func locationManager(didUpdateLocation location: LMLocation) {
        
    }
    
    func locationManager(didChangeAuthorization isGranted: Bool) {
        
    }
}
