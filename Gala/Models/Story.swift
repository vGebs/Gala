//
//  StoryModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import SwiftUI

struct StoryMeta {
    var postID_timeAndDatePosted: String
    var userCore: UserCore
}

struct Story {
    var meta: StoryMeta
    var image: UIImage
}
