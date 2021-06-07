//
//  LocationService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-06-03.
//

import Foundation
import Combine
import CoreLocation
import SwiftUI
import MapKit

class LocationService: NSObject, ObservableObject {
    struct Coordinates{
        var longitude: Double = 0
        var latitude: Double = 0
    }
    
    static let shared = LocationService()
    
    @Published var coordinates = Coordinates()
    
    @Published var city = ""
    @Published var country = ""
    
    private let locationManager = CLLocationManager()

    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            self.locationManager.stopUpdatingLocation()
            print("Stopped updating location")
        }
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        self.coordinates.latitude = location.coordinate.latitude
        self.coordinates.longitude = location.coordinate.longitude
        let loc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        loc.fetchCityAndCountry { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            self.city = city
            print(self.city)
            self.country = country
        }
    }
}

extension LocationService {
    
    enum DistanceType {
        case metric
        case imperial
        case minutesHours
    }
    
    func getTravelTime(to: Coordinates, travelType: MKDirectionsTransportType, distanceType: DistanceType) -> AnyPublisher<String?, Error> {
        
        let request = MKDirections.Request()
        
        let from = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude))
        let to = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: to.latitude, longitude: to.longitude))
        
        request.source = MKMapItem(placemark: from)
        request.destination = MKMapItem(placemark: to)
        request.transportType = travelType
        
        let direction = MKDirections(request: request)
        
        return Future<String?, Error> { promise in
            direction.calculateETA { response, error in
                if let error = error {
                    return promise(.failure(error))
                }
                
                if let response = response {
                    
                    switch distanceType {
                    
                    case .metric:
                        let formatter = MKDistanceFormatter()
                        formatter.units = .metric
                        let formatted = formatter.string(fromDistance: response.distance)
                        return promise(.success(formatted))
                        
                    case .imperial:
                        let formatter = MKDistanceFormatter()
                        formatter.units = .metric
                        let formatted = formatter.string(fromDistance: response.distance)
                        return promise(.success(formatted))
                        
                    case .minutesHours:
                        
                        let minutes: Int = Int(response.expectedTravelTime) / 60
                        
                        if minutes >= 60 {
                            let hours: Int = minutes / 60
                            let remainderMins = minutes % 60
                            
                            if remainderMins > 0 {
                                let finalString = "\(hours)h \(remainderMins)min away"
                                return promise(.success(finalString))
                                
                            } else {
                                let finalString = "\(hours)h away"
                                return promise(.success(finalString))
                                
                            }
                        } else {
                            let finalString = "\(minutes)min away"
                            return promise(.success(finalString))
                        }
                    }
                    
                } else {
                    return promise(.success(nil))
                }
            }
        }.eraseToAnyPublisher()
    }
}
