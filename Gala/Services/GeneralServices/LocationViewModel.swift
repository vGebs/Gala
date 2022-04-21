//
//  LocationViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-03-30.
//

import Foundation
import Combine

class LocationViewModel: ObservableObject {
    @Published var city = ""
    @Published var country = ""
    
    private var cancellables: [AnyCancellable] = []
    
    init(coordinate: Coordinate) {
//        LocationService.shared.getCityAndCountry(lat: coordinate.lat, long: coordinate.lng)
//            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                switch completion {
//                case .failure(let error):
//                    print("LocationViewModel: \(error.localizedDescription)")
//                case .finished:
//                    print("LocationViewModel: Finished getting city and country")
//                }
//            } receiveValue: { [weak self] tuple in
//                if let city = tuple?.0{
//                    self?.city = city
//                }
//
//                if let country = tuple?.1 {
//                    self?.country = country
//                }
//            }
//            .store(in: &cancellables)
    }
}
