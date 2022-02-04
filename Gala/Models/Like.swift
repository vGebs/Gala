//
//  Like.swift
//  Gala
//
//  Created by Vaughn on 2021-09-03.
//

import Foundation

struct Like {
    var dateOfLike: Date
    var likerUID: String
    var likedUID: String
    
    var nameOfLiker: String
    var birthdayOfLiker: String
    var storyID: Date?
}

struct InComingLike {
    var like: Like
    var docID: String
}

struct StoryLike {
    var like: Like
    var docID: String
}
