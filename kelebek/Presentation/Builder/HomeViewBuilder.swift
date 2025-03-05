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
        
        let managedContext = CoreDataHelper.shared.getManagedContextWithMergePolicy()
        let locationEntityCoreDataManager = LocationEntityCoreDataManager(managedContext: managedContext)

        let locationUseCase = LocationUseCase(locationManager: locationManager,
                                              locationEntityCoreDataManager: locationEntityCoreDataManager)
        
        let viewModel = HomeViewModel(locationUseCase: locationUseCase)
        
        let viewController = HomeViewController(viewModel: viewModel)
        
        return viewController
    }
}

/*
 let coreDataManager = CoreDataManager()
 let locationRepository = LocationRepositoryImplementation(coreDataManager: coreDataManager)
*/
