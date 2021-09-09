//
//  StoryModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import SwiftUI

struct Story {
    var meta: StoryMeta
    var image: UIImage
}

struct StoryMeta {
    var uid: String
    var postID: String
    var timeAndDatePosted: String
}

struct StoryMetaWithDocID {
    var meta: StoryMeta
    var docID: String
}

struct StoryWithDocID {
    var story: Story
    var docID: String
}
