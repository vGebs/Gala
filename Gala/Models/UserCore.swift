//
//  UserSimpleModel.swift
//  Gala
//
//  Created by Vaughn on 2021-07-08.
//

import SwiftUI
import FirebaseFirestoreSwift


struct SearchRadiusComponents {
    var coordinate: Coordinate
    var willingToTravel: Int
}

struct AgeRangePreference {
    var minAge: Int
    var maxAge: Int
}

struct UserBasic {
    var uid: String
    var name: String
    var birthdate: Date
    var gender: String
    var sexuality: String
}

struct UserCore {
    var userBasic: UserBasic
    var ageRangePreference: AgeRangePreference
    var searchRadiusComponents: SearchRadiusComponents
}

struct InComingUserCore {
    var userCore: UserCore
    var liked: Bool
}
