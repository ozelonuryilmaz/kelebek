//
//  HomeViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation
import CoreLocation
import Combine

typealias CurrentLocationSubject = PassthroughSubject<CLLocation?, Never>
typealias IsTrackingActiveSubject = PassthroughSubject<Bool, Never>

protocol IHomeViewModel {
    var currentLocationSubject: CurrentLocationSubject { get }
    var isTrackingActiveSubject: IsTrackingActiveSubject { get }
    
    func requestLocationPermission()
    func startTracking()
    func stopTracking()
    func resetRoute()
}

final class HomeViewModel: IHomeViewModel {
    
    private let locationUseCase: ILocationUseCase
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var currentLocationSubject = CurrentLocationSubject()
    private(set) var isTrackingActiveSubject = IsTrackingActiveSubject()

    init(locationUseCase: ILocationUseCase) {
        self.locationUseCase = locationUseCase

        loadLastSavedLocation()
        observeLocation()
    }
    
    private func loadLastSavedLocation() {
        if let savedLocation = locationUseCase.getLastSavedLocation() {
            currentLocationSubject.send(savedLocation)
        }
    }
    
    private func observeLocation() {
        locationUseCase.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocationSubject.send(location)
            }
            .store(in: &cancellables)
    }
}

// MARK: LocationUseCase
extension HomeViewModel {
    
    func requestLocationPermission() {
        locationUseCase.requestLocationPermission()
    }
    
    func startTracking() {
        locationUseCase.startTracking()
        isTrackingActiveSubject.send(true)
    }
    
    func stopTracking() {
        locationUseCase.stopTracking()
        isTrackingActiveSubject.send(false)
    }
    
    func resetRoute() {
        locationUseCase.clearAllLocations()
        currentLocationSubject.send(nil)
    }
}
