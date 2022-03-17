//
//  Bundle.swift
//  Gala
//
//  Created by Vaughn on 2022-03-16.
//

import Foundation

struct StoryBundle: Identifiable, Hashable {
    var id = UUID().uuidString
    var profileName: String
    var profileImage: String
    var isSeen: Bool = false
    var stories: [Story]
}

struct Story: Identifiable, Hashable {
    var id = UUID().uuidString
    var imageURL: String
}
