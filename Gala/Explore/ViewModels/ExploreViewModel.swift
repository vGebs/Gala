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
    var likeService = LikesService.shared
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
        Publishers.Zip(
            recents.getRecents(),
            likeService.getPeopleILiked()
        )
        .subscribe(on: DispatchQueue.global(qos: .userInteractive))
        .sink { completion in
            switch completion {
            case .failure(let err):
                print("ExploreViewModel: failed to load recents")
                print("ExploreViewModel-Error: \(err)")
            case .finished:
                print("ExploreViewModel: Got recents")
            }
        } receiveValue: { [weak self] recents, iLiked in
            var final: [UserCore] = []
            if let recents = recents {
                for i in 0..<recents.count {
                    print("ExploreViewModel-Recents: \(recents[i])")
                    if iLiked.count > 0 {
                        for j in 0..<iLiked.count {
                            if recents[i].uid != iLiked[j].like.likedUID {
                                final.append(recents[i])
                                print("finalll: \(final)")
                            }
                        }
                        self?.recentlyJoinedProfiles = final
                    } else {
                        self?.recentlyJoinedProfiles = recents
                    }
                }
            } else {
                print("ExploreViewModel recents: nil")
            }
        }
        .store(in: &self.cancellables)
    }
}

//We need to fetch all recents, as well as all of our likes
//We need to then cross reference them
//If we pulled a user we already liked, we need to either:
//  1. Not show them **WE WILL DO THIS**
//  2. Be able to unlike them
