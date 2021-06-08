//
//  ExploreViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import Combine
import SwiftUI

class ExploreViewModel: ObservableObject {
    
    @Published var recentlyJoinedProfiles: [ProfileModel] = [
        ProfileModel(name: "Vaughn", birthday: Date(), location: "Regina, Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "Vaughn", birthday: Date(), location: "Regina, Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "Vaughn", birthday: Date(), location: "Regina, Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R")
    ]
    
    init() {
        //Fetch recentlyJoinedProfiles in my area
    }
}
