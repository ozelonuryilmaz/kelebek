//
//  HomeViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject {
    func updateMap(with location: LMLocation)
    func removeAllAnnotation()
    func setTrackingButtonTitle(_ title: String)
    func showLocationPermissionAlert()
}

protocol IHomeViewModel: LMLocationManagerDelegate {
    var delegate: HomeViewModelDelegate? { get set }

    // Actions
    func onTrackingButtonTapped()
    func onResetRouteButtonTapped()
}

final class HomeViewModel: BaseViewModel, IHomeViewModel {
    
    weak var delegate: HomeViewModelDelegate? = nil

    // MARK: Inject
    private let locationManager: ILocationManager
    private let locationCoreDataManager: ILocationEntityCoreDataManager

    // MARK: Definitions
    private var isTrackingActive: Bool = false
    private var trackingButtonTitle: String {
        return isTrackingActive ? "Konum Takibini Durdur" : "Konum Takibini Başlat"
    }

    init(locationManager: ILocationManager,
         locationCoreDataManager: ILocationEntityCoreDataManager) {
        self.locationManager = locationManager
        self.locationCoreDataManager = locationCoreDataManager
        super.init()
        self.locationManager.delegate = self
        self.requestLocationPermission()
    }
}

// MARK: Actions
extension HomeViewModel {
    
    func onTrackingButtonTapped() {
        if isTrackingActive { stopTracking() }
        else { requestLocationPermission() }
        delegate?.setTrackingButtonTitle(trackingButtonTitle)
    }
    
    func onResetRouteButtonTapped() {
        self.clearAllFixedLocations()
        self.delegate?.removeAllAnnotation()
    }
}

// MARK: LocationManager
private extension HomeViewModel {
    
    func requestLocationPermission() {
        locationManager.requestPermission()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        isTrackingActive = true
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTrackingActive = false
    }
}

// MARK: CoreDataManager
private extension HomeViewModel {
    
    func updateFixedLocation(_ location: LMLocation) {
        locationCoreDataManager.insertLocationEntity(location)
    }
    
    func clearAllFixedLocations() {
        locationCoreDataManager.clearAllLocationEntity()
    }
}

// MARK: LMLocationManagerDelegate
extension HomeViewModel {
    
    func locationManager(didUpdateLocation location: LMLocation) {
        delegate?.updateMap(with: location)
        delegate?.setTrackingButtonTitle(trackingButtonTitle)
    }

    func locationManager(didChangeAuthorization isGranted: Bool) {
        if isGranted { self.startTracking() }
        else { delegate?.showLocationPermissionAlert() }
    }
}
