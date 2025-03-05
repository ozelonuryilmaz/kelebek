//
//  HomeViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation
import CoreLocation
import Combine

protocol IHomeViewModel {
    var currentLocation: CLLocation? { get }
    var isTrackingActive: Bool { get set }
    
    func requestLocationPermission()
    func startTracking()
    func stopTracking()
    func resetRoute()
}

final class HomeViewModel: IHomeViewModel {
    
    private let locationUseCase: ILocationUseCase
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var currentLocation: CLLocation?
    @Published var isTrackingActive: Bool = false
    
    init(locationUseCase: ILocationUseCase) {
        self.locationUseCase = locationUseCase
        loadLastSavedLocation()
        setupBindings()
    }
    
    private func loadLastSavedLocation() {
        if let savedLocation = locationUseCase.getLastSavedLocation() {
            currentLocation = savedLocation
        }
    }
    
    private func setupBindings() {
        locationUseCase.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocation = location
            }
            .store(in: &cancellables)
    }
    
    func requestLocationPermission() {
        locationUseCase.requestLocationPermission()
    }
    
    func startTracking() {
        locationUseCase.startTracking()
        isTrackingActive = true
    }
    
    func stopTracking() {
        locationUseCase.stopTracking()
        isTrackingActive = false
    }
    
    func resetRoute() {
        locationUseCase.clearAllLocations()
        currentLocation = nil
    }
}
