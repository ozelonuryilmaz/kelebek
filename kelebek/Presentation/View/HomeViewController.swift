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
        // TODO: Kullanıcı konum takip izni UserDefaults'a tutulmalı. Uygulama açıldığında güncellenmeli
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        DispatchQueue.main.async { [weak self] in
            self?.mapView.addAnnotation(annotation)
        }
    }
    
    func setRegion(coordinate: LMLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)

        DispatchQueue.main.async { [weak self] in
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
    
    func didFetchAddress(_ result: Result<String, Error>) {
        switch result {
        case .success(let address):
            showSystemAlert(title: "Adres Bilgisi", message: address)
        case .failure(let error):
            showSystemAlert(title: "Hata", message: "Adres alınamadı: \(error.localizedDescription)")
        }
    }
    
    func loadSavedAnnotations(_ locations: [LocationModel]) {
        // TODO: 500+ Annotions'da ClusterAnnotation düzenlenmesi gerekecek
        let annotations = locations.map { model -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            let coordinate = model.location.coordinate
            annotation.coordinate = LMLocationCoordinate2D(latitude: coordinate.latitude,
                                                           longitude: coordinate.longitude)
            return annotation
        }

        DispatchQueue.main.async { [weak self] in
            self?.mapView.addAnnotations(annotations)
        }
    }
    
    func drawRoutes(with routes: [[LMLocationCoordinate2D]]) {
        let polylines = routes
            .filter { $0.count > 1 }
            .map { MKPolyline(coordinates: $0, count: $0.count) }

        DispatchQueue.main.async { [weak self] in
            polylines.forEach {
                self?.mapView.addOverlay($0)
            }
        }
    }

    func addPolylineBetweenAnnotations(start: LMLocationCoordinate2D, end: LMLocationCoordinate2D) {
        // TODO: Polyline yerine Direction tercih edilecek
        let coordinates = [start, end]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        DispatchQueue.main.async { [weak self] in
            self?.mapView.addOverlay(polyline)
        }
    }
}

// MARK: MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 2
            renderer.lineDashPattern = [2, 4]
            return renderer
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        viewModel.fetchAddress(for: annotation.coordinate)
    }
}
