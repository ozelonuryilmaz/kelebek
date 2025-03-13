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
}

protocol ILocationManager {
    var lastSentLocation: LMLocation? { get }

    func requestPermission(completion: @escaping (Bool) -> Void)
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func clearLastKnownLocation()
}

final class LocationManager: NSObject, ILocationManager {
    
    private let locationManager = CLLocationManager()
    private let locationDistance = CLLocationDistance(100)
    private var permissionCompletion: ((Bool) -> Void)?
    private(set) var lastSentLocation: LMLocation? = nil
    weak var delegate: LocationManagerDelegate? = nil

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
   
    func requestPermission(completion: @escaping (Bool) -> Void) {
        self.permissionCompletion = completion
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        default:
            completion(false)
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
        if let completion = permissionCompletion {
            let isGranted = (status == .authorizedAlways || status == .authorizedWhenInUse)
            completion(isGranted)
            permissionCompletion = nil
        }
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("konum izni verildi")
        case .denied, .restricted:
            print("konum izni verilmedi")
        case .notDetermined:
            print("konum izni henüz verilmedi")
        default:
            print("izin durumu bilinmiyor")
        }
    }
}
