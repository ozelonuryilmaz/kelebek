//
//  HomeViewBuilder.swift
//  kelebek
//
//  Created by Onur Yılmaz on 4.03.2025.
//

import UIKit

enum HomeViewBuilder {
    
    static func build() -> UIViewController {
        
        let locationManager: ILocationManager = LocationManager()
        
        let coreDataHelper = CoreDataHelper()
        let managedContext = coreDataHelper.getManagedContextWithMergePolicy()
        let locationCoreDataManager: ILocationEntityCoreDataManager = LocationEntityCoreDataManager(managedContext: managedContext)
        
        let processRoutesUseCase: IProcessRoutesUseCase = ProcessRoutesUseCase()
        let shouldDrawLineUseCase: IShouldDrawLineUseCase = ShouldDrawLineUseCase()

        let viewModel: IHomeViewModel = HomeViewModel(locationManager: locationManager,
                                                      locationCoreDataManager: locationCoreDataManager,
                                                      processRoutesUseCase: processRoutesUseCase,
                                                      shouldDrawLineUseCase: shouldDrawLineUseCase)
        
        let viewController = HomeViewController(viewModel: viewModel)
        
        return viewController
    }
}
