//
//  RecentlyJoinedViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import Combine
import SwiftUI

class SmallUserViewModel: ObservableObject {
    @Published var profile: ProfileModel
    
    init(profile: ProfileModel){
        self.profile = profile
    }
}