//
//  HomeViewController.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit
import MapKit
import Combine

final class HomeViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    
    // MARK: Inject
    private let viewModel: IHomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private var routePolyline: MKPolyline?
    
    init(viewModel: IHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HomeViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        title = "Harita"
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // TODO: Kontrol edilecek
        viewModel.requestLocationPermission()
        viewModel.startTracking()
        
        
    }

    private func bindViewModel() {
        observeCurrentLocation()
        observeIsTrackingStatus()
    }
    
    private func observeCurrentLocation() {
        viewModel.currentLocationSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let location else { return }
                self?.updateMap(with: location)
            }
            .store(in: &cancellables)
    }
    
    private func observeIsTrackingStatus() {
        viewModel.isTrackingActiveSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isTrackingActive in
                print("*** \(isTrackingActive.description)")
            }
            .store(in: &cancellables)
    }

    private func updateMap(with location: CLLocation) {
        let coordinate = location.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Güncellenen Konum"
        mapView.addAnnotation(annotation)
        centerMap(on: location)
    }

    private func centerMap(on location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

}

extension HomeViewController: MKMapViewDelegate {

}
