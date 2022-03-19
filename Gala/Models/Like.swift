//
//  Like.swift
//  Gala
//
//  Created by Vaughn on 2021-09-03.
//

import Foundation
import SwiftUI

struct Like: Identifiable {
    let id = UUID().uuidString
    var dateOfLike: Date
    var likerUID: String
    var likedUID: String
    
    var nameOfLiker: String
    var birthdayOfLiker: String
    var storyID: Date?
}

struct LikeWithProfile: Identifiable {
    let id = UUID().uuidString
    let like: Like
    let userCore: UserCore
    let profileImg: UIImage?
}

struct SimpleStoryLike {
    var likedUID: String
    var pid: Date
    var docID: String
}

struct InComingLike {
    var like: Like
    var docID: String
}

struct StoryLike {
    var like: Like
    var docID: String
}
