//
//  Like.swift
//  Gala
//
//  Created by Vaughn on 2021-09-03.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct Like: Identifiable {
    let id = UUID().uuidString
    var dateOfLike: Date
    var likerUID: String
    var likedUID: String
    
    var nameOfLiker: String
    var birthdayOfLiker: String
    var storyID: Date?
    var changeType: DocumentChangeType?
    
    init(dateOfLike: Date, likerUID: String, likedUID: String, nameOfLiker: String, birthdayOfLiker: String, storyID: Date? = nil, changeType: DocumentChangeType? = nil) {
        self.dateOfLike = dateOfLike
        self.likedUID = likedUID
        self.likerUID = likerUID
        self.nameOfLiker = nameOfLiker
        self.birthdayOfLiker = birthdayOfLiker
        self.storyID = storyID
        self.changeType = changeType
    }
}

struct LikeWithProfile: Identifiable {
    let id = UUID().uuidString
    var like: Like
    let userCore: UserCore
    let profileImg: UIImage?
}

struct SimpleStoryLike {
    var likedUID: String
    var pid: Date
    var docID: String
    var changeType: DocumentChangeType?
    
    init(likedUID: String, pid: Date, docID: String, changeType: DocumentChangeType? = nil) {
        self.likedUID = likedUID
        self.docID = docID
        self.pid = pid
        self.changeType = changeType
    }
}

struct InComingLike {
    var like: Like
    var docID: String
}

struct StoryLike {
    var like: Like
    var docID: String
}
