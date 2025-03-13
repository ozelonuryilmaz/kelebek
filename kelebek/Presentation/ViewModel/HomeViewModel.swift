//
//  HomeViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation

protocol IHomeViewModel {
    var isTrackingActive: Bool { get }
    
    // LocationUseCase
    func requestLocationPermission()
    func startTracking()
    func stopTracking()
    
    // Repository
    func updateFixedLocation(_ location: LMLocation)
    func clearAllFixedLocations()
}

final class HomeViewModel: BaseViewModel, IHomeViewModel {
    
    private let locationManager: ILocationManager
    private(set) var isTrackingActive: Bool = false

    init(locationManager: ILocationManager) {
        self.locationManager = locationManager
        super.init()
    }
}

// MARK: LocationUseCase
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

// MARK: Repository
extension HomeViewModel {
    
    func updateFixedLocation(_ location: LMLocation) {
        
    }
    
    func clearAllFixedLocations() {
        
    }
}
