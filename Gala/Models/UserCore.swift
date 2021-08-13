//
//  UserSimpleModel.swift
//  Gala
//
//  Created by Vaughn on 2021-07-08.
//

import SwiftUI
import FirebaseFirestoreSwift


//add:
//ageMin
//ageMax
//radius away
//
struct UserCore: Codable {
    var uid: String 
    var name: String
    var age: Date
    var gender: String
    var sexuality: String
    var longitude: Double
    var latitude: Double
    
    enum CodingKeys: String, CodingKey{
        case uid
        case name
        case age
        case gender
        case sexuality
        case longitude
        case latitude
    }
}
