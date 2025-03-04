//
//  LocationPermissionManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation
import CoreLocation

protocol ILocationPermissionManager {
    
}

final class LocationPermissionManager: NSObject, ILocationPermissionManager {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
}

extension LocationPermissionManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
}
