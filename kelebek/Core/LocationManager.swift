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
}

final class LocationManager: NSObject, ILocationManager {

    weak var delegate: LocationManagerDelegate? = nil
    
    private let locationManager = CLLocationManager()
    private let locationDistance = CLLocationDistance(100)

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
}

// MARK: Permission & Location
extension LocationManager {
   
    func requestPermission() {
        switch locationManager.authorizationStatus {
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
        BackgroundLocationTaskManager.shared.scheduleBackgroundTask()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [LMLocation]) {
        guard let latestLocation = locations.last else { return }
        delegate?.locationManager(didUpdateLocation: latestLocation)
        BackgroundLocationTaskManager.shared.scheduleBackgroundTask()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let isGranted = status == .authorizedAlways || status == .authorizedWhenInUse
        delegate?.locationManager(didChangeAuthorization: isGranted)
    }
}
