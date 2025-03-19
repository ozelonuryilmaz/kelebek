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
    func didFetchAddress(_ result: Result<String, Error>)
    func loadSavedAnnotations(_ locations: [LocationModel])
    func drawRoutes(with routes: [[LMLocationCoordinate2D]])
    func addPolylineBetweenAnnotations(start: LMLocationCoordinate2D, end: LMLocationCoordinate2D)
}

protocol IHomeViewModel: LMLocationManagerDelegate {
    var delegate: HomeViewModelDelegate? { get set }
    
    func setupLocationManager()
    func fetchAddress(for coordinate: LMLocationCoordinate2D)

    // Actions
    func onTrackingButtonTapped()
    func onResetRouteButtonTapped()
}

final class HomeViewModel: BaseViewModel, IHomeViewModel {
    
    weak var delegate: HomeViewModelDelegate? = nil

    // MARK: Inject
    private let locationManager: ILocationManager
    private let locationCoreDataManager: ILocationEntityCoreDataManager
    private let processRoutesUseCase: IProcessRoutesUseCase
    private let shouldDrawLineUseCase: IShouldDrawLineUseCase
    private let geocoderService: IGeocoderService

    // MARK: Definitions
    private var lastLocation: LMLocationCoordinate2D? = nil
    private var task: Task<Void, Never>? = nil
    private var isTrackingActive: Bool = false
    private var trackingButtonTitle: String {
        return isTrackingActive ? "Konum Takibini Durdur" : "Konum Takibini Başlat"
    }

    init(locationManager: ILocationManager,
         locationCoreDataManager: ILocationEntityCoreDataManager,
         processRoutesUseCase: IProcessRoutesUseCase,
         shouldDrawLineUseCase: IShouldDrawLineUseCase,
         geocoderService: IGeocoderService) {
        self.locationManager = locationManager
        self.locationCoreDataManager = locationCoreDataManager
        self.processRoutesUseCase = processRoutesUseCase
        self.shouldDrawLineUseCase = shouldDrawLineUseCase
        self.geocoderService = geocoderService
        super.init()
    }
    
    internal func setupLocationManager() {
        self.locationManager.delegate = self
        self.requestLocationPermission()
        self.loadSavedLocations()
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
        locationCoreDataManager.fetchAllLocations()
    }
    
    func insertLocation(_ location: LMLocation) {
        locationCoreDataManager.insertLocationEntity(location)
    }
    
    func clearAllLocations() {
        locationCoreDataManager.clearAllLocationEntity()
    }
}

// MARK: Location Props
private extension HomeViewModel {
    
    func loadSavedLocations() {
        let allLocations = getAllLocations()
        lastLocation = allLocations.last?.location.coordinate
        let route = processRoutesUseCase.execute(locationModel: allLocations)
        delegate?.loadSavedAnnotations(allLocations)
        delegate?.drawRoutes(with: route)
    }
    
    func addPolylineBetweenAnnotations(lastLocation: LMLocationCoordinate2D?, newLocation: LMLocationCoordinate2D) {
        if let lastLocation = lastLocation, shouldDrawLineUseCase.execute(lastLocation: lastLocation, newLocation: newLocation) {
            self.delegate?.addPolylineBetweenAnnotations(start: lastLocation, end: newLocation)
        }
        self.lastLocation = newLocation
    }
}

// MARK: LMLocationManagerDelegate
extension HomeViewModel {
    
    func locationManager(didUpdateLocation location: LMLocation) {
        delegate?.setTrackingButtonTitle(trackingButtonTitle)
        delegate?.updateMap(with: location)
        addPolylineBetweenAnnotations(lastLocation: self.lastLocation, newLocation: location.coordinate)
        insertLocation(location)
    }

    func locationManager(didChangeAuthorization isGranted: Bool) {
        if isGranted { self.startTracking() }
        else { delegate?.showLocationPermissionAlert() }
    }
}

// MARK: Fetch Address
extension HomeViewModel {
    
    func fetchAddress(for coordinate: LMLocationCoordinate2D) {
        task?.cancel()

        task = Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                let address = try await self.geocoderService.fetchAddress(for: coordinate)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.delegate?.didFetchAddress(.success(address))
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.delegate?.didFetchAddress(.failure(error))
                }
            }
        }
    }

}
