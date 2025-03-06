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
        
        let coreDataHelper = CoreDataHelper()
        let managedContext = coreDataHelper.getManagedContextWithMergePolicy()
        let locationEntityCoreDataManager = LocationEntityCoreDataManager(managedContext: managedContext)

        let locationUseCase = LocationUseCase(locationManager: locationManager,
                                              locationEntityCoreDataManager: locationEntityCoreDataManager)
        
        let routeUIModel = RouteUIModel()
        
        let viewModel = HomeViewModel(locationUseCase: locationUseCase,
                                      routeUIModel: routeUIModel)
        
        let viewController = HomeViewController(viewModel: viewModel)
        
        return viewController
    }
}
