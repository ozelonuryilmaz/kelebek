//
//  GeocoderService.swift
//  kelebek
//
//  Created by Onur Yılmaz on 19.03.2025.
//

import CoreLocation

protocol IGeocoderService {
    func fetchAddress(for coordinate: LMLocationCoordinate2D) async throws -> String
}

final class GeocoderService: IGeocoderService {
    
    private let geocoder = CLGeocoder()
    
    func fetchAddress(for coordinate: LMLocationCoordinate2D) async throws -> String {
        geocoder.cancelGeocode()

        let location = LMLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let address = placemarks?.first.map {
                    "\($0.name ?? ""), \($0.locality ?? ""), \($0.administrativeArea ?? ""), \($0.country ?? "")"
                } ?? "Adres Bulunamadı"

                continuation.resume(returning: address)
            }
        }
    }
    
    private func cancelGeocoding() {
        geocoder.cancelGeocode()
    }
}
