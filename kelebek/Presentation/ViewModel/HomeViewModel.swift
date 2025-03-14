//
//  HomeViewModel.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject {
    func updateMap(with location: LMLocation)
    func clearMap()
    func setTrackingButtonTitle(_ title: String)
    func showLocationPermissionAlert()
    func loadSavedAnnotations(_ locations: [LocationModel])
    func drawRoutes(with routes: [[LMLocationCoordinate2D]])
    func addPolylineBetweenAnnotations(start: LMLocationCoordinate2D, end: LMLocationCoordinate2D)
}

protocol IHomeViewModel: LMLocationManagerDelegate {
    var delegate: HomeViewModelDelegate? { get set }
    
    func setupLocationManager()

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
    private var lastLocation: LMLocationCoordinate2D? = nil
    private var isTrackingActive: Bool = false
    private var trackingButtonTitle: String {
        return isTrackingActive ? "Konum Takibini Durdur" : "Konum Takibini Başlat"
    }

    init(locationManager: ILocationManager,
         locationCoreDataManager: ILocationEntityCoreDataManager) {
        self.locationManager = locationManager
        self.locationCoreDataManager = locationCoreDataManager
        super.init()
    }
    
    internal func setupLocationManager() {
        self.locationManager.delegate = self
        self.requestLocationPermission()
        self.loadSavedLocations()
        self.getAllRoutes()
    }
    
    private func loadSavedLocations() {
        let savedLocations = getAllLocations()
        lastLocation = savedLocations.last?.location.coordinate
        delegate?.loadSavedAnnotations(savedLocations)
    }
    
    private func getAllRoutes() {
        let routes = locationCoreDataManager.getAllRoutes()
        delegate?.drawRoutes(with: routes)
    }
    
    func addNewLocation(_ newLocation: LMLocationCoordinate2D) {
        if let lastLocation = lastLocation {
            let lastLMLocation = LMLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
            let newLMLocation = LMLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
            let distance = lastLMLocation.distance(from: newLMLocation)

            if distance < Constants.MapDistance.max {
                delegate?.addPolylineBetweenAnnotations(start: lastLocation, end: newLocation)
            }
        }
        lastLocation = newLocation
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
        self.clearAllLocations()
        self.delegate?.clearMap()
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

    func getAllLocations() -> [LocationModel] {
        locationCoreDataManager.getAllLocationsEntity()
    }
    
    func insertLocation(_ location: LMLocation) {
        locationCoreDataManager.insertLocationEntity(location)
    }
    
    func clearAllLocations() {
        locationCoreDataManager.clearAllLocationEntity()
    }
}

// MARK: LMLocationManagerDelegate
extension HomeViewModel {
    
    func locationManager(didUpdateLocation location: LMLocation) {
        delegate?.setTrackingButtonTitle(trackingButtonTitle)
        delegate?.updateMap(with: location)
        addNewLocation(location.coordinate)
        insertLocation(location)
    }

    func locationManager(didChangeAuthorization isGranted: Bool) {
        if isGranted { self.startTracking() }
        else { delegate?.showLocationPermissionAlert() }
    }
}
