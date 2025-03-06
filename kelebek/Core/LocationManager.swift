//
//  LocationPermissionManager.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit // TODO: UIKit kullanmamalıyım. Düzeltilecek

import CoreLocation
import Combine

typealias LocationPublisher = AnyPublisher<CLLocation, Never>
typealias LMLocation = CLLocation

protocol ILocationManager {
    var locationPublisher: LocationPublisher { get }
    var lastSentLocation: LMLocation? { get }

    func requestPermission(completion: @escaping (Bool) -> Void)
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func clearLastKnownLocation()
}

final class LocationManager: NSObject, ILocationManager {
    
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let locationDistance = CLLocationDistance(100)

    private var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var permissionCompletion: ((Bool) -> Void)?
    
    private(set) var lastSentLocation: LMLocation? = nil

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

        if let lastLocation = lastSentLocation {
            if latestLocation.distance(from: lastLocation) < locationDistance {
                return
            }
        }
        
        lastSentLocation = latestLocation
        locationSubject.send(latestLocation)
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

// MARK: Private Background Mode
private extension LocationManager {
    
    func registerBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "LocationTracking",
                                                                    expirationHandler: {
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
