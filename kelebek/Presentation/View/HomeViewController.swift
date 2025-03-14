//
//  HomeViewController.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit
import MapKit

final class HomeViewController: KelebekBaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var trackingButton: UIButton!
    @IBOutlet private weak var resetRouteButton: UIButton!
    
    // MARK: Inject
    private let viewModel: IHomeViewModel

    init(viewModel: IHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HomeViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func initialComponents() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        viewModel.delegate = self
        viewModel.setupLocationManager()
    }
    
    override func registerEvents() {
        trackingButton.addTarget(self, action: #selector(self.btnTrackingTapped), for: .touchUpInside)
        resetRouteButton.addTarget(self, action: #selector(self.btnResetRouteTapped), for: .touchUpInside)
    }
}

// MARK: Actions
private extension HomeViewController {

    @objc func btnResetRouteTapped() {
        viewModel.onResetRouteButtonTapped()
    }

    @objc func btnTrackingTapped() {
        viewModel.onTrackingButtonTapped()
    }
}

// MARK: Annotation
private extension HomeViewController {

    func addAnnotation(coordinate: LMLocationCoordinate2D) {
        DispatchQueue.main.async { [weak self] in
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self?.mapView.addAnnotation(annotation)
        }
    }
    
    func setRegion(coordinate: LMLocationCoordinate2D) {
        DispatchQueue.main.async { [weak self] in
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            self?.mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {

    func updateMap(with location: LMLocation) {
        let coordinate = location.coordinate
        addAnnotation(coordinate: coordinate)
        setRegion(coordinate: coordinate)
    }
    
    func clearMap() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }

    func setTrackingButtonTitle(_ title: String) {
        trackingButton.setTitle(title, for: .normal)
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
    
    func loadSavedAnnotations(_ locations: [LocationModel]) {
        DispatchQueue.main.async { [weak self] in
            // TODO: 500+ Annotions'da ClusterAnnotation düzenlenmesi gerekecek
            let annotations = locations.map { model -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                let coordinate = model.location.coordinate
                annotation.coordinate = LMLocationCoordinate2D(latitude: coordinate.latitude,
                                                               longitude: coordinate.longitude)
                return annotation
            }
            self?.mapView.addAnnotations(annotations)
        }
    }
    
    func drawRoutes(with routes: [[LMLocationCoordinate2D]]) {
        DispatchQueue.main.async { [weak self] in
            for route in routes {
                if route.count > 1 {
                    let polyline = MKPolyline(coordinates: route, count: route.count)
                    self?.mapView.addOverlay(polyline)
                }
            }
        }
    }

    func addPolylineBetweenAnnotations(start: LMLocationCoordinate2D, end: LMLocationCoordinate2D) {
        DispatchQueue.main.async { [weak self] in
            let coordinates = [start, end]
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self?.mapView.addOverlay(polyline)
        }
    }
}

// MARK: MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8)
            renderer.lineWidth = 2
            renderer.lineDashPattern = [2, 4]
            return renderer
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        fetchAddress(for: annotation.coordinate)
    }
}

// MARK: Geocoder
private extension HomeViewController {
    
    func fetchAddress(for coordinate: LMLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(
            LMLocation(latitude: coordinate.latitude,
                       longitude: coordinate.longitude)) { [weak self] placemarks, error in
                           let address = placemarks?.first.map { "\($0.name ?? ""), \($0.locality ?? ""), \($0.administrativeArea ?? ""), \($0.country ?? "")" } ?? "Adres Bulunamadı"
                           self?.showSystemAlert(title: "Adres Bilgisi", message: address)
        }
    }
}
