//
//  StoryModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import SwiftUI

//Some changes:
//  - We are going to make 'postID_timeAndDatePosted' an array
//Therefore we need to:
//  1. Change the myStories array in StoryService to just one
//      StoryMeta object (which is an optional)
//  2. When we make a new post, we add the date to the array (which
//      is the storyID).
//  3. We will also have to change the return for 'getMyStories' from -> [StoryMeta],
//      to -> StoryMeta
//      
//  We also likely will not need the 'Story' Model becuase we are pulling the images
//      once we get the meta and pass it to the object. Wait and see what is needed.


struct StoryMeta {
    var postID_timeAndDatePosted: [String]
    var userCore: UserCore
}

struct Story {
    var meta: StoryMeta
    var image: UIImage
}

struct StoryAndLikes: Identifiable {
    var id = UUID()
    var storyID: Date
    var likes: [Int]
}
