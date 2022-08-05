//
//  Message.swift
//  Gala
//
//  Created by Vaughn on 2022-02-10.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable {
    let id = UUID()
    let message: String
    let toID: String
    let fromID: String
    let time: Date
    var openedDate: Date?
    let docID: String
    let changeType: DocumentChangeType?
    
    init(message: String, toID: String, fromID: String, time: Date, openedDate: Date? = nil, docID: String, changeType: DocumentChangeType? = nil) {
        self.message = message
        self.toID = toID
        self.fromID = fromID
        self.time = time
        self.openedDate = openedDate
        self.docID = docID
        self.changeType = changeType
    }
}
