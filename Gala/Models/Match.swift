//
//  Match.swift
//  Gala
//
//  Created by Vaughn on 2022-02-11.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Match: Identifiable {
    let id = UUID()
    let matchedUID: String
    let timeMatched: Date
    let docID: String
    let changeType: DocumentChangeType?
    
    init(matchedUID: String, timeMatched: Date, docID: String, changeType: DocumentChangeType? = nil) {
        self.matchedUID = matchedUID
        self.timeMatched = timeMatched
        self.docID = docID
        self.changeType = changeType
    }
}

struct MatchedUserCore: Identifiable {
    let id = UUID()
    var uc: UserCore
    var profileImg: UIImage?
    var timeMatched: Date
    var lastMessage: Date?
    var matchDocID: String
}
