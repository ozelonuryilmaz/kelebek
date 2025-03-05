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
    @IBOutlet private weak var userTrackingButton: UIButton!
    
    // MARK: Inject
    private let viewModel: IHomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
    }
    
    private func bindViewModel() {
        observeCurrentLocation()
        observeIsTrackingStatus()
    }
    
    private func observeCurrentLocation() {
        viewModel.currentLocationSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                print("*** \(location?.description ?? "")")
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
}
