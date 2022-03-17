//
//  StoryViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-03-16.
//

import Foundation
import Combine

class InstaStoryViewModel: ObservableObject {
    @Published var stories: [StoryBundle] = [
        StoryBundle(profileName: "Tony", profileImage: "Tony", stories: [
            Story(imageURL: "endgame"),
            Story(imageURL: "endgame2"),
            Story(imageURL: "Loki")
        ]),
        StoryBundle(profileName: "Gatsby", profileImage: "Gatsby", stories: [
            Story(imageURL: "Wolf"),
            Story(imageURL: "inception")
        ])
    ]
    
    @Published var showStory = false
    @Published var currentStory = ""
}
