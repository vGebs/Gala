//
//  ExploreViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import Combine
import SwiftUI

class ExploreViewModel: ObservableObject {
    
    @Published var recentlyJoinedViewModel: RecentlyJoinedViewModel
    @Published var storiesViewModel: StoriesViewModel
    
    func checkLikes() {
        print("LikesContainer likes: \(LikesContainer.shared.iLiked)")
    }
    
    init() {
        recentlyJoinedViewModel = RecentlyJoinedViewModel()
        storiesViewModel = StoriesViewModel()
    }
}

//We need to fetch all recents, as well as all of our likes
//We need to then cross reference them
//If we pulled a user we already liked, we need to either:
//  1. Not show them **WE WILL DO THIS**
//  2. Be able to unlike them
