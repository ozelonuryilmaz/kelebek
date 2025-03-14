//
//  ShouldDrawLineUseCase.swift
//  kelebek
//
//  Created by Onur Yılmaz on 14.03.2025.
//

protocol IShouldDrawLineUseCase {
    func execute(lastLocation: LMLocationCoordinate2D?, newLocation: LMLocationCoordinate2D) -> Bool
}

class ShouldDrawLineUseCase: IShouldDrawLineUseCase {
    
    func execute(lastLocation: LMLocationCoordinate2D?, newLocation: LMLocationCoordinate2D) -> Bool {
        guard let lastLocation = lastLocation else { return false }
        
        let lastLMLocation = LMLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
        let newLMLocation = LMLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
        let distance = lastLMLocation.distance(from: newLMLocation)

        return distance < Constants.MapDistance.max
    }
}
