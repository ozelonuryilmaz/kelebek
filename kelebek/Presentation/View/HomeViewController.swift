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
    private var cancellables = Set<AnyCancellable>()
    private var currentAnnotation: MKPointAnnotation?
    
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
        viewModel.startTracking()
        trackingButton.addTarget(self, action: #selector(self.toggleTracking), for: .touchUpInside)
        goToRouteButton.addTarget(self, action: #selector(self.goToRoute), for: .touchUpInside)
        resetRouteButton.addTarget(self, action: #selector(self.resetRoute), for: .touchUpInside)
    }
    
    private func setupUI() {
        mapView.delegate = self
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
            }
            .store(in: &cancellables)
    }
    
    private func observeCurrentRoute() {
        viewModel.currentRouteSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let route else { return }
                self?.updateRoute(with: route)
            }
            .store(in: &cancellables)
    }

    private func updateMap(with location: CLLocation) {
        let coordinate = location.coordinate

        if let annotation = currentAnnotation {
            mapView.removeAnnotation(annotation)
        }

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Güncellenen Konum"
        mapView.addAnnotation(annotation)

        currentAnnotation = annotation

        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    private func updateRoute(with route: MKPolyline) {
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(route)
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
}

// MARK: OnTap
private extension HomeViewController {
    
    @objc func goToRoute() {
        let goAnywhere = CLLocation(latitude: 41.0053, longitude: 28.9770)
        viewModel.updateFixedLocation(goAnywhere)
        viewModel.startTracking()
    }

    @objc func resetRoute() {
        viewModel.resetRoute()
        mapView.removeOverlays(mapView.overlays)
    }
    
    @objc func toggleTracking() {
        if viewModel.isTrackingActive {
            viewModel.stopTracking()
        } else {
            viewModel.requestLocationPermission { [weak self] isGranted in
                guard let self else { return }
                if isGranted {
                    self.viewModel.startTracking()
                } else {
                    self.showLocationPermissionAlert()
                }
            }
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
