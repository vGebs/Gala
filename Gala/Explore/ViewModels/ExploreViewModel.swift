//
//  ExploreViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import Combine
import SwiftUI

class ExploreViewModel: ObservableObject {
    
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
    
    //@Published var matchStories: MatchStoryViewModel
    @Published var recentlyJoinedViewModel: RecentlyJoinedViewModel
    
    
    init() {
        //matchStories = MatchStoryViewModel()
        recentlyJoinedViewModel = RecentlyJoinedViewModel()
    }
}

//We need to fetch all recents, as well as all of our likes
//We need to then cross reference them
//If we pulled a user we already liked, we need to either:
//  1. Not show them **WE WILL DO THIS**
//  2. Be able to unlike them
