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
    @IBOutlet private weak var trackingButton: UIButton!
    @IBOutlet private weak var goToRouteButton: UIButton!
    @IBOutlet private weak var resetRouteButton: UIButton!
    
    // MARK: Inject
    private let viewModel: IHomeViewModel

    // MARK: Definitions
    private let geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()
    private var currentAnnotation: MKPointAnnotation? = nil
    
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
        checkLocationPermissionAndStart()
    }
    
    private func setupUI() {
        mapView.delegate = self
        trackingButton.addTarget(self, action: #selector(self.btnTrackingTapped), for: .touchUpInside)
        goToRouteButton.addTarget(self, action: #selector(self.btnGoToRouteTapped), for: .touchUpInside)
        resetRouteButton.addTarget(self, action: #selector(self.btnResetRouteTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        observeCurrentLocation()
        observeCurrentRoute()
    }
    
    private func observeCurrentLocation() {
        viewModel.currentLocationSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let location else { return }
                self?.updateMap(with: location)
                self?.updateTrackingButtonTitle(isTrackingActive: true)
            }
            .store(in: &cancellables)
    }
    
    private func observeCurrentRoute() {
        viewModel.currentRouteSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self else { return }
                if let route = route {
                    self.updateRoute(with: route)
                } else {
                    self.removeOverlays()
                }
            }
            .store(in: &cancellables)
    }

    private func updateMap(with location: CLLocation) {
        let coordinate = location.coordinate
        removeAnnotation()
        addAnnotation(coordinate: coordinate)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    private func updateRoute(with route: MKPolyline) {
        removeOverlays()
        mapView.addOverlay(route)
    }
    
    private func removeOverlays() {
        mapView.removeOverlays(mapView.overlays)
    }
}

// MARK: MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        fetchAddress(for: annotation.coordinate)
    }
}

// MARK: Annotation
private extension HomeViewController {
    
    func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        currentAnnotation = annotation
    }

    func removeAnnotation() {
        if let annotation = currentAnnotation {
            mapView.removeAnnotation(annotation)
        }
    }
}

// MARK: OnTap
private extension HomeViewController {
    
    @objc func btnGoToRouteTapped() {
        let goAnywhere = CLLocation(latitude: 41.0053, longitude: 28.9770)
        viewModel.updateFixedLocation(goAnywhere)
        viewModel.generateRouteFromCurrentLocation(to: goAnywhere)
    }

    @objc func btnResetRouteTapped() {
        viewModel.resetRoute()
        removeOverlays()
    }

    @objc func btnTrackingTapped() {
        if viewModel.isTrackingActive {
            viewModel.stopTracking()
        } else {
            checkLocationPermissionAndStart()
        }
        updateTrackingButtonTitle(isTrackingActive: viewModel.isTrackingActive)
    }
}

// MARK: Private Props
private extension HomeViewController {
    
    func updateTrackingButtonTitle(isTrackingActive: Bool) {
        let title = isTrackingActive ? "Konum Takibini Durdur" : "Konum Takibini Başlat"
        trackingButton.setTitle(title, for: .normal)
    }
    
    func checkLocationPermissionAndStart() {
        viewModel.requestLocationPermission { [weak self] isGranted in
            guard let self else { return }
            if isGranted {
                self.viewModel.startTracking()
            } else {
                self.showLocationPermissionAlert()
            }
        }
    }
    
    func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self, error == nil, let placemark = placemarks?.first else {
                self?.showAddressAlert(address: "Adres bulunamadı.")
                return
            }
            
            let address = """
            \(placemark.name ?? ""),
            \(placemark.locality ?? ""),
            \(placemark.administrativeArea ?? ""),
            \(placemark.country ?? "")
            """
            
            self.showAddressAlert(address: address)
        }
    }

    func showAddressAlert(address: String) {
        let alert = UIAlertController(title: "Adres Bilgisi", message: address, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Konum İzni Gerekli",
            message: "Konum takibini başlatabilmek için lütfen ayarlardan izin verin.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ayarları Aç", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}
