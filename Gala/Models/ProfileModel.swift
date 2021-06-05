//
//  ProfileModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Foundation
import FirebaseFirestoreSwift

struct ProfileModel: Codable {
    var name: String
    var birthday: Date
    var id: String
    var bio: String?
    var gender: String
    var sexuality: String
    var job: String?
    var school: String?
    //var images: [ImageModel]?
    //var profilePic: ImageModel?

    enum CodingKeys: String, CodingKey{
        case name
        case birthday = "age"
        case id
        case bio
        case gender
        case sexuality
        case job
        case school
    }
}