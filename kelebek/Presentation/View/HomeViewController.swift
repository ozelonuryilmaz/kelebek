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
        viewModel.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
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

    func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func setRegion(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
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

// MARK: HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {

    func updateMap(with location: LMLocation) {
        let coordinate = location.coordinate
        addAnnotation(coordinate: coordinate)
        setRegion(coordinate: coordinate)
    }
    
    func removeAllAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
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
}

// MARK: MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        fetchAddress(for: annotation.coordinate)
    }
}
