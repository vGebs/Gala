//
//  UserAbout.swift
//  Gala
//
//  Created by Vaughn on 2021-07-15.
//

import Combine
import FirebaseFirestoreSwift

struct UserAbout: Codable {
    var bio: String?
    var job: String?
    var school: String?
    
    enum CodingKeys: String, CodingKey{
        case bio
        case job
        case school
    }
}
