//
//  Match.swift
//  Gala
//
//  Created by Vaughn on 2022-02-11.
//

import Foundation
import SwiftUI

struct Match: Identifiable {
    let id = UUID()
    let matchedUID: String
    let timeMatched: Date
}

struct MatchedUserCore: Identifiable {
    let id = UUID()
    let uc: UserCore
    var profileImg: UIImage?
    var timeMatched: Date
}
