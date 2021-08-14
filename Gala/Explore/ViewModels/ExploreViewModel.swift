//
//  ExploreViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import Combine
import SwiftUI

class ExploreViewModel: ObservableObject {
    
    var recents = RecentlyJoinedUserService.shared
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
        print("ExploreViewModel: beginning to fetch Recents")
        //Fetch recentlyJoinedProfiles in my area
        recents.getRecents()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("ExploreViewModel: \(error.localizedDescription)")
                case .finished:
                    print("ExploreViewModel: Finished fetching recents nearby")
                }
            } receiveValue: { [weak self] users in
                if let users = users {
                    self?.recentlyJoinedProfiles = users
                    print("ExploreViewModel recents: \(users)")
                } else {
                    print("ExploreViewModel recents: nil")
                }
            }
            .store(in: &self.cancellables)
    }
}
