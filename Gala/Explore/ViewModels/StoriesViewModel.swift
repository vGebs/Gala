//
//  StoriesViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import Combine
import SwiftUI

class StoriesViewModel: ObservableObject {
    @Published var stories: [StoryModel] = [
        StoryModel(story: UIImage(), name: "1", userID: "123"),
        StoryModel(story: UIImage(), name: "2", userID: "123"),
        StoryModel(story: UIImage(), name: "3", userID: "123"),
        StoryModel(story: UIImage(), name: "4", userID: "123"),
        StoryModel(story: UIImage(), name: "5", userID: "123"),
        StoryModel(story: UIImage(), name: "6", userID: "123"),
        StoryModel(story: UIImage(), name: "7", userID: "123"),
        StoryModel(story: UIImage(), name: "8", userID: "123")
    ]
}

struct StoryModel: Identifiable {
    var id = UUID()
    var story: UIImage
    var name: String
    var userID: String
}

class StoryViewModel: ObservableObject {
    var story: StoryModel
    
    init(_ story: StoryModel){
        self.story = story
    }
}
