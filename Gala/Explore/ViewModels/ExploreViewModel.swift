//
//  ExploreViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import Combine
import SwiftUI

class ExploreViewModel: ObservableObject {
    
    var recents = UserCoreService.shared
    var cancellables: [AnyCancellable] = []
    
    @Published var matchStories: [StoryModel] = [
        StoryModel(story: UIImage(), name: "1", userID: "123"),
        StoryModel(story: UIImage(), name: "2", userID: "123"),
        StoryModel(story: UIImage(), name: "3", userID: "123"),
        StoryModel(story: UIImage(), name: "4", userID: "123"),
        StoryModel(story: UIImage(), name: "5", userID: "123"),
        StoryModel(story: UIImage(), name: "6", userID: "123"),
        StoryModel(story: UIImage(), name: "7", userID: "123"),
        StoryModel(story: UIImage(), name: "8", userID: "123"),
        StoryModel(story: UIImage(), name: "9", userID: "123"),
        StoryModel(story: UIImage(), name: "10", userID: "123"),
        StoryModel(story: UIImage(), name: "1", userID: "123"),
        StoryModel(story: UIImage(), name: "2", userID: "123"),
        StoryModel(story: UIImage(), name: "3", userID: "123"),
        StoryModel(story: UIImage(), name: "4", userID: "123"),
        StoryModel(story: UIImage(), name: "5", userID: "123"),
        StoryModel(story: UIImage(), name: "6", userID: "123"),
        StoryModel(story: UIImage(), name: "7", userID: "123"),
        StoryModel(story: UIImage(), name: "8", userID: "123"),
        StoryModel(story: UIImage(), name: "9", userID: "123"),
        StoryModel(story: UIImage(), name: "10", userID: "123")
    ]
    
    @Published var recentlyJoinedProfiles: [UserCore] = []
    
    init() {
        //Fetch Match Stories
        
        //Fetch recentlyJoinedProfiles in my area
        recents.getAllRecents(radiusKM: 50)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("ExploreViewModel: \(error.localizedDescription)")
                case .finished:
                    print("ExploreViewModel: Finished fetching recents nearby")
                }
            } receiveValue: { users in
                self.recentlyJoinedProfiles = users
                print("ExploreViewModel recents: \(users)")
            }
            .store(in: &self.cancellables)
    }
}


//@Published var recentlyJoinedProfiles: [ProfileModel] = [
//    ProfileModel(name: "1", birthday: Date(), latitude: 51.5074, longitude: 0.12780, userID: "1234", gender: "Male", sexuality: "Straight"),
//    ProfileModel(name: "2", birthday: Date(), latitude: 51.5074, longitude: 0.12780, userID: "1234", gender: "Male", sexuality: "Straight"),
//    ProfileModel(name: "3", birthday: Date(), latitude: 51.5074, longitude: 0.12780, userID: "1234", gender: "Male", sexuality: "Straight"),
//    ProfileModel(name: "4", birthday: Date(), latitude: 51.5074, longitude: 0.12780, userID: "1234", gender: "Male", sexuality: "Straight"),
//    ProfileModel(name: "5", birthday: Date(), latitude: 51.5074, longitude: 0.12780, userID: "1234", gender: "Male", sexuality: "Straight"),
//    ProfileModel(name: "6", birthday: Date(), latitude: 51.5074, longitude: 0.12780, userID: "1234", gender: "Male", sexuality: "Straight"),
//    ProfileModel(name: "7", birthday: Date(), latitude: 51.5074, longitude: 0.12780, userID: "1234", gender: "Male", sexuality: "Straight"),
//    ProfileModel(name: "8", birthday: Date(), latitude: 51.5074, longitude: 0.12780, userID: "1234", gender: "Male", sexuality: "Straight")
//]
