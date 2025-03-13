//
//  LocationPermissionManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import CoreLocation

typealias LMLocation = CLLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManager(didUpdateLocation location: LMLocation)
    func locationManager(didChangeAuthorization isGranted: Bool)
}

protocol ILocationManager {
    var delegate: LocationManagerDelegate? { get set }

    func requestPermission()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func clearLastKnownLocation()
}

final class LocationManager: NSObject, ILocationManager {
        
    weak var delegate: LocationManagerDelegate? = nil
    
    private let locationManager = CLLocationManager()
    private let locationDistance = CLLocationDistance(100)
    private var lastSentLocation: LMLocation? = nil

    override init() {
        super.init()
        self.initLocationManager()
    }
    
    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = locationDistance
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    internal func clearLastKnownLocation() {
        self.lastSentLocation = nil
    }
}

// MARK: Permission & Location
extension LocationManager {
   
    func requestPermission() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            delegate?.locationManager(didChangeAuthorization: true)
        default:
            delegate?.locationManager(didChangeAuthorization: false)
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [LMLocation]) {
        guard let latestLocation = locations.last else { return }

        if let lastLocation = lastSentLocation, latestLocation.distance(from: lastLocation) < locationDistance {
            return
        }
        
        lastSentLocation = latestLocation
        delegate?.locationManager(didUpdateLocation: latestLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let isGranted = status == .authorizedAlways || status == .authorizedWhenInUse
        delegate?.locationManager(didChangeAuthorization: isGranted)
    }
}
