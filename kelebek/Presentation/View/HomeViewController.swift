//
//  HomeViewController.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit
import MapKit
import Combine

// MARK: Coordinator, Repository, ViewState, UIModel kullanımı için "https://github.com/ozelonuryilmaz/berkel" Repository kontrole edebilirsiniz

final class HomeViewController: KelebekBaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var trackingButton: UIButton!
    @IBOutlet private weak var goToRouteButton: UIButton!
    @IBOutlet private weak var resetRouteButton: UIButton!
    
    // MARK: Inject
    private let viewModel: IHomeViewModel

    // MARK: Definitions
    private var cancellables = Set<AnyCancellable>()
    private var currentAnnotation: MKPointAnnotation? = nil
    
    init(viewModel: IHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HomeViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func initialComponents() {
        mapView.delegate = self
        checkLocationPermissionAndStart()
        observeCurrentLocation()
        observeCurrentRoute()
    }
    
    override func registerEvents() {
        trackingButton.addTarget(self, action: #selector(self.btnTrackingTapped), for: .touchUpInside)
        goToRouteButton.addTarget(self, action: #selector(self.btnGoToRouteTapped), for: .touchUpInside)
        resetRouteButton.addTarget(self, action: #selector(self.btnResetRouteTapped), for: .touchUpInside)
    }
}

// MARK: Observe
private extension HomeViewController {

    func observeCurrentLocation() {
        viewModel.currentLocationSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let location else { return }
                self?.updateMap(with: location)
                self?.updateTrackingButtonTitle(isTrackingActive: true)
            }
            .store(in: &cancellables)
    }

    func observeCurrentRoute() {
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
}

// MARK: Annotation
private extension HomeViewController {
    
    func updateMap(with location: LMLocation) {
        let coordinate = location.coordinate
        removeAnnotation()
        addAnnotation(coordinate: coordinate)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    func removeAnnotation() {
        if let annotation = currentAnnotation {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        currentAnnotation = annotation
    }
}

// MARK: Route
private extension HomeViewController {
    
    func updateRoute(with route: MKPolyline) {
        if let existingOverlay = mapView.overlays.first(where: { $0 is MKPolyline }) {
            mapView.removeOverlay(existingOverlay)
        }
        mapView.addOverlay(route)
    }
    
    func removeOverlays() {
        mapView.removeOverlays(mapView.overlays)
    }
}

// MARK: Button Actions
private extension HomeViewController {
    
    @objc func btnGoToRouteTapped() {
        // Varış noktası dinamik olarak değiştirilebilir.
        let goAnywhere = LMLocation(latitude: 41.0053, longitude: 28.9770)
        viewModel.updateFixedLocation(goAnywhere)
        viewModel.generateRouteFromCurrentLocation(to: goAnywhere)
    }

    @objc func btnResetRouteTapped() {
        viewModel.clearAllFixedLocations()
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

// MARK: Permission
private extension HomeViewController {
    
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
    
    func showLocationPermissionAlert() {
        self.showSystemAlert(
            title: "Konum İzni Gerekli",
            message: "Konum takibini başlatabilmek için lütfen ayarlardan izin verin.",
            positiveButtonText: "Ayarları Aç",
            positiveButtonClickListener: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            },
            negativeButtonText: "İptal"
        )
    }
}

// MARK: Private Props
private extension HomeViewController {
    
    func updateTrackingButtonTitle(isTrackingActive: Bool) {
        let title = isTrackingActive ? "Konum Takibini Durdur" : "Konum Takibini Başlat"
        trackingButton.setTitle(title, for: .normal)
    }
}

// MARK: Fetch Address
private extension HomeViewController {
    
    func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(
            LMLocation(latitude: coordinate.latitude,
                       longitude: coordinate.longitude)) { [weak self] placemarks, error in
                           
                           let address = placemarks?.first.map { "\($0.name ?? ""), \($0.locality ?? ""), \($0.administrativeArea ?? ""), \($0.country ?? "")" } ?? "Adres Bulunamadı"
                           self?.showSystemAlert(title: "Adres Bilgisi", message: address)
        }
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
