//
//  HomeViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation
import CoreLocation
import Combine
import MapKit

typealias CurrentLocationSubject = PassthroughSubject<CLLocation?, Never>
typealias CurrentRouteSubject = PassthroughSubject<MKPolyline?, Never>

protocol IHomeViewModel {
    var currentLocationSubject: CurrentLocationSubject { get }
    var currentRouteSubject: CurrentRouteSubject { get }
    var isTrackingActive: Bool { get }
    
    func requestLocationPermission(completion: @escaping (Bool) -> Void)
    func startTracking()
    func stopTracking()

    func generateRouteFromCurrentLocation(to fixedLocation: CLLocation)
    func updateFixedLocation(_ location: CLLocation)
    func resetRoute()
}

final class HomeViewModel: IHomeViewModel {
    
    private let locationUseCase: ILocationUseCase
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var currentLocationSubject = CurrentLocationSubject()
    private(set) var currentRouteSubject = CurrentRouteSubject()
    private(set) var isTrackingActive: Bool = false

    init(locationUseCase: ILocationUseCase) {
        self.locationUseCase = locationUseCase
        observeLocation()
    }

    private func observeLocation() {
        locationUseCase.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocationSubject.send(location)
                self?.checkAndGenerateRoute(from: location)
            }
            .store(in: &cancellables)
    }
}

// MARK: LocationUseCase
extension HomeViewModel {

    func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        locationUseCase.requestLocationPermission { isGranted in
            completion(isGranted)
        }
    }
    
    func startTracking() {
        locationUseCase.startTracking()
        isTrackingActive = true
    }
    
    func stopTracking() {
        locationUseCase.stopTracking()
        isTrackingActive = false
    }
}

// MARK: Route
extension HomeViewModel {
    
    func updateFixedLocation(_ location: CLLocation) {
        locationUseCase.saveFixedLocation(location)
    }
    
    func resetRoute() {
        locationUseCase.clearAllFixedLocations()
    }
    
    func generateRouteFromCurrentLocation(to fixedLocation: CLLocation) {
        guard let userLocation = locationUseCase.getLastKnownLocation() else { return }
        generateRoute(from: userLocation, to: fixedLocation)
    }
    
    private func checkAndGenerateRoute(from location: CLLocation) {
        guard let fixedLocation = locationUseCase.getLastSavedFixedLocation() else { return }
        generateRoute(from: location, to: fixedLocation)
    }

    private func generateRoute(from userLocation: CLLocation, to fixedLocation: CLLocation) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: fixedLocation.coordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else { return }
            self.currentRouteSubject.send(route.polyline)
        }
    }
}
