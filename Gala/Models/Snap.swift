//
//  Snap.swift
//  Gala
//
//  Created by Vaughn on 2022-02-17.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Snap: Identifiable {
    let id = UUID()
    let fromID: String
    let toID: String
    let snapID_timestamp: Date
    var openedDate: Date?
    var imgAssetData: Data?
    var vidURL: URL?
    var isImage: Bool
    var caption: Caption?
    let docID: String
    let changeType: DocumentChangeType?
    
    init(fromID: String, toID: String, snapID: Date, openedDate: Date? = nil, imgAssetData: Data? = nil, vidURL: URL? = nil, isImage: Bool, caption: Caption? = nil, docID: String, changeType: DocumentChangeType? = nil) {
        self.fromID = fromID
        self.toID = toID
        self.snapID_timestamp = snapID
        self.openedDate = openedDate
        self.imgAssetData = imgAssetData
        self.vidURL = vidURL
        self.isImage = isImage
        self.caption = caption
        self.docID = docID
        self.changeType = changeType
    }
}

struct Caption {
    let captionText: String
    let textBoxHeight: CGFloat
    let yCoordinate: CGFloat
}
