//
//  Message.swift
//  Gala
//
//  Created by Vaughn on 2022-02-10.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let message: String
    let toID: String
    let fromID: String
    let time: Date
    var opened: Bool
    let docID: String 
}
