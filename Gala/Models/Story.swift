//
//  StoryModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import SwiftUI

struct StoryMeta {
    var postID: String
    var timeAndDatePosted: String
    var userCore: UserCore
}

struct StoryMetaWithDocID {
    var meta: StoryMeta
    var docID: String
}

struct Story {
    var meta: StoryMeta
    var image: UIImage
}

struct StoryWithDocID {
    var story: Story
    var docID: String
}
