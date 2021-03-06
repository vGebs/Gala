//
//  RecentlyJoinedViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import Combine
import SwiftUI

class SmallUserViewModel: ObservableObject {
    @Published private(set) var profile: UserCore?
    @Published private(set) var city: String = ""
    @Published private(set) var country: String = ""
    @Published private(set) var img: UIImage?
    
    private var cancellables: [AnyCancellable] = []
    
    deinit {
        print("SmallUserViewModel: Deinitializing")
    }
    
    init(profile: UserCore){
        self.profile = profile
        
        getCityAndCountry()
        getProfileImage()
    }
    
    init(profile: UserCore, img: UIImage?) {
        self.profile = profile
        self.img = img
        getCityAndCountry()
    }
    
    //Need to make getUserCore in UserCoreService using async and await
    // then pull the usercore, followed by getCityAndCountry and getProfileImage
    init(uid: String) {
        Task {
            let uc = await UserCoreService.shared.getUserCore_iOS15(uid: uid)
            
            if let uc = uc {
                DispatchQueue.main.async {
                    self.profile = uc
                    self.getCityAndCountry()
                    self.getProfileImage()
                }
            }
        }
    }
    
    private func getCityAndCountry() {
        LocationService.shared.getCityAndCountry(lat: profile!.searchRadiusComponents.coordinate.lat, long: profile!.searchRadiusComponents.coordinate.lng)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("SmallUserViewModel: \(error)")
                case .finished:
                    print("SmallUserViewModel: Finished getting city and country")
                }
            } receiveValue: { [weak self] tuple in
                if let city = tuple?.0{
                    self?.city = city
                }
                
                if let country = tuple?.1 {
                    self?.country = country
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func getProfileImage() {
        ProfileImageService.shared.getProfileImage(uid: profile!.userBasic.uid, index: "0")
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("SmallUserViewModel: Error fetching profileImg -> \(error)")
                case .finished:
                    print("SmallUserViewModel: Finished fetching profile img")
                }
            } receiveValue: { [weak self] img in
                if let img = img {
                    print("SmallUserViewModel: \(img)")
                    self?.img = img
                } else {
                    print("SmallUserViewModel: img is nil")
                }
            }
            .store(in: &self.cancellables)
    }
}
