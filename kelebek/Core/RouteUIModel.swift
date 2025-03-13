//
//  RouteUseCase.swift
//  kelebek
//
//  Created by Onur Yılmaz on 6.03.2025.
//

import Foundation
import MapKit
import Combine

typealias CurrentLocationSubject = PassthroughSubject<LMLocation?, Never>
typealias CurrentRouteSubject = PassthroughSubject<MKPolyline?, Never>

protocol IRouteUIModel {
    func generateRoute(from userLocation: LMLocation, to fixedLocation: LMLocation) -> AnyPublisher<MKPolyline?, Never>
}

struct RouteUIModel: IRouteUIModel {
    
    func generateRoute(from userLocation: LMLocation, to fixedLocation: LMLocation) -> AnyPublisher<MKPolyline?, Never> {
        return Future<MKPolyline?, Never> { promise in
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: fixedLocation.coordinate))
            request.transportType = .automobile

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                if let route = response?.routes.first {
                    promise(.success(route.polyline))
                } else {
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
