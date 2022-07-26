//
//  Snap.swift
//  Gala
//
//  Created by Vaughn on 2022-02-17.
//

import Foundation
import SwiftUI

struct Snap: Identifiable {
    let id = UUID()
    let fromID: String
    let toID: String
    let snapID_timestamp: Date
    var openedDate: Date?
//    var img: UIImage?
//    var vidURL: URL?
    var assetData: Data?
    var isImage: Bool
    let docID: String
}
