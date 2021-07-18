//
//  RecentlyJoinedViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import Combine
import SwiftUI

class SmallUserViewModel: ObservableObject {
    @Published var profile: UserCore
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var img: UIImage?
    
    private var cancellables: [AnyCancellable] = []
    
    init(profile: UserCore){
        self.profile = profile
        
        getCityAndCountry()
        getProfileImage()
    }
    
    private func getCityAndCountry() {
        LocationService.shared.getCityAndCountry(lat: profile.latitude, long: profile.longitude)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                
            } receiveValue: { tuple in
                if let city = tuple?.0{
                    self.city = city
                }
                
                if let country = tuple?.1 {
                    self.country = country
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func getProfileImage() {
        ProfileImageService.shared.getProfileImage(id: profile.uid, index: "0")
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("SmallUserViewModel: Error fetching profileImg -> \(error)")
                case .finished:
                    print("SmallUserViewModel: Finished fetching profile img")
                }
            } receiveValue: { img in
                if let img = img {
                    print("SmallUserViewModel: \(img)")
                    self.img = img
                } else {
                    print("SmallUserViewModel: img is nil")
                }
            }
            .store(in: &self.cancellables)
    }
}
