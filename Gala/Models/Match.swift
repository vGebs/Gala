//
//  Match.swift
//  Gala
//
//  Created by Vaughn on 2022-02-11.
//

import Foundation

struct Match: Identifiable {
    let id = UUID()
    let matchedUID: String
    let timeMatched: Date
}
