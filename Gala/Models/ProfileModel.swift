//
//  ProfileModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Foundation
import FirebaseFirestoreSwift

struct ProfileModel: Identifiable { //Codable
    var id = UUID()
//    var name: String
//    var birthday: Date
//    var latitude: Double
//    var longitude: Double
//    var userID: String
//    var bio: String?
//    var gender: String
//    var sexuality: String
//    var ageMinPref: Int
//    var ageMaxPref: Int
//    var willingToTravel: Int
//    var job: String?
//    var school: String?
    
    var userAbout: UserAbout
    var userCore: UserCore
    var images: [ImageModel]

//    enum CodingKeys: String, CodingKey{
//        case name
//        case birthday = "age"
//        case latitude
//        case longitude
//        case userID = "id"
//        case bio
//        case gender
//        case sexuality
//        case ageMinPref
//        case ageMaxPref
//        case willingToTravel
//        case job
//        case school
//    }
}
