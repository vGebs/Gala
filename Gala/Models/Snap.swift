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
    var imgAssetData: Data?
    var vidURL: URL?
    var isImage: Bool
    let docID: String
}
