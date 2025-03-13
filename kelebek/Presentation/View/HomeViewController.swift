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

    // MARK: Definitions
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
        mapView.showsUserLocation = true
        checkLocationPermissionAndStart()
    }
    
    override func registerEvents() {
        trackingButton.addTarget(self, action: #selector(self.btnTrackingTapped), for: .touchUpInside)
        resetRouteButton.addTarget(self, action: #selector(self.btnResetRouteTapped), for: .touchUpInside)
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

// MARK: Button Actions
private extension HomeViewController {

    @objc func btnResetRouteTapped() {
        viewModel.clearAllFixedLocations()
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
        viewModel.requestLocationPermission()
        /* TODO: LocationManagerDelegate'deki fonksiyondan tetikle
         if isGranted {
             self.viewModel.startTracking()
         } else {
             self.showLocationPermissionAlert()
         }
         */
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        fetchAddress(for: annotation.coordinate)
    }
}
