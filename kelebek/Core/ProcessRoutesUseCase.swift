//
//  ProcessRoutesUseCase.swift
//  kelebek
//
//  Created by Onur Yılmaz on 14.03.2025.
//

import Foundation

protocol IProcessRoutesUseCase {
    func execute(locationModel: [LocationModel]) -> [[LMLocationCoordinate2D]]
}

final class ProcessRoutesUseCase: IProcessRoutesUseCase {
    
    func execute(locationModel: [LocationModel]) -> [[LMLocationCoordinate2D]] {
        let locations = locationModel.map({ $0.location.coordinate })
        var routes: [[LMLocationCoordinate2D]] = []
        var currentRoute: [LMLocationCoordinate2D] = []
        var previousLocation: LMLocation?

        for location in locations {
            let currentLocation = LMLocation(latitude: location.latitude, longitude: location.longitude)

            if let lastLocation = previousLocation {
                let distance = lastLocation.distance(from: currentLocation)
                if distance > Constants.MapDistance.max {
                    if !currentRoute.isEmpty {
                        routes.append(currentRoute)
                    }
                    currentRoute = []
                }
            }

            currentRoute.append(location)
            previousLocation = currentLocation
        }

        if !currentRoute.isEmpty {
            routes.append(currentRoute)
        }

        return routes
    }
}
