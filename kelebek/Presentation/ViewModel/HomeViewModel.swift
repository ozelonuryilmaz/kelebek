//
//  HomeViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation
import Combine

protocol IHomeViewModel {
    var currentLocationSubject: CurrentLocationSubject { get }
    var currentRouteSubject: CurrentRouteSubject { get }
    var isTrackingActive: Bool { get }
    
    // LocationUseCase
    func requestLocationPermission(completion: @escaping (Bool) -> Void)
    func startTracking()
    func stopTracking()
    func updateFixedLocation(_ location: LMLocation)
    func clearAllFixedLocations()

    // Route
    func generateRouteFromCurrentLocation(to fixedLocation: LMLocation)
}

final class HomeViewModel: BaseViewModel, IHomeViewModel {
    
    private let locationUseCase: ILocationUseCase
    private let routeUIModel: IRouteUIModel
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var currentLocationSubject = CurrentLocationSubject()
    private(set) var currentRouteSubject = CurrentRouteSubject()
    private(set) var isTrackingActive: Bool = false

    init(locationUseCase: ILocationUseCase,
         routeUIModel: IRouteUIModel) {
        self.locationUseCase = locationUseCase
        self.routeUIModel = routeUIModel
        super.init()

        self.observeLocation()
    }
}

// MARK: LocationUseCase
extension HomeViewModel {
    
    private func observeLocation() {
        locationUseCase.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocationSubject.send(location)
                self?.checkAndGenerateRoute(from: location)
            }
            .store(in: &cancellables)
    }

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
        clearRoute()
    }

    func updateFixedLocation(_ location: LMLocation) {
        locationUseCase.saveFixedLocation(location)
    }
    
    func clearAllFixedLocations() {
        locationUseCase.clearAllFixedLocations()
    }
}

// MARK: RouteUseCase
extension HomeViewModel {
    
    private func executeRouteGeneration(from source: LMLocation, to destination: LMLocation) {
        routeUIModel.generateRoute(from: source, to: destination)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.currentRouteSubject.send(route)
            }
            .store(in: &cancellables)
    }
    
    private func clearRoute() {
        currentRouteSubject.send(nil)
    }

    func generateRouteFromCurrentLocation(to fixedLocation: LMLocation) {
        guard let userLocation = locationUseCase.getLastKnownLocation(), isTrackingActive else { return }
        executeRouteGeneration(from: userLocation, to: fixedLocation)
    }

    private func checkAndGenerateRoute(from location: LMLocation) {
        guard let fixedLocation = locationUseCase.getLastSavedFixedLocation(), isTrackingActive else { return }
        executeRouteGeneration(from: location, to: fixedLocation)
    }
}
