//
//  LocationPermissionManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit
import CoreLocation
import Combine

typealias LocationPublisher = AnyPublisher<CLLocation, Never>

protocol ILocationManager {
    var locationPublisher: LocationPublisher { get }
    func requestPermission()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

final class LocationManager: NSObject, ILocationManager {
    
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let locationDistance = CLLocationDistance(100)
    private var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var lastSentLocation: CLLocation? = nil
    
    internal var locationPublisher: LocationPublisher {
        locationSubject.eraseToAnyPublisher()
    }
    
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
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            locationManager.startUpdatingLocation()
        }
        registerBackgroundTask()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        endBackgroundTask()
    }
}

// MARK: CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        if let lastLocation = lastSentLocation, latestLocation.distance(from: lastLocation) < locationDistance {
            return
        }
        
        lastSentLocation = latestLocation
        locationSubject.send(latestLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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

// MARK: Private Background Mode
private extension LocationManager {
    
    func registerBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "LocationTracking", expirationHandler: {
            self.endBackgroundTask()
        })
    }
    
    func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
}
