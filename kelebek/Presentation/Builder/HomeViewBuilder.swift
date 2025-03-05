//
//  HomeViewBuilder.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit

enum HomeViewBuilder {
    static func build() -> UIViewController {
        let locationManager = LocationManager()
        let coreDataManager = CoreDataManager()
        let locationUseCase = LocationUseCase(locationManager: locationManager,
                                              coreDataManager: coreDataManager)
        let viewModel = HomeViewModel(locationUseCase: locationUseCase)
        let viewController = HomeViewController(viewModel: viewModel)
        return viewController
    }
}
