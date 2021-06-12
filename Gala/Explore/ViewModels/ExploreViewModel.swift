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
        ProfileModel(name: "Vaughn", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "joe", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "sam", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "ye", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "yee", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "yeye", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "bb", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "aa", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "qq", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "rr", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "tt", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "yy", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "uu", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R"),
        ProfileModel(name: "ii", birthday: Date(), city: "Regina", country: "Canada", userID: "1234", bio: "yee", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R")
    ]
    
    init() {
        //Fetch recentlyJoinedProfiles in my area
    }
}
