//
//  VibeCoverImage.swift
//  Gala
//
//  Created by Vaughn on 2022-03-17.
//

import Foundation
import SwiftUI

struct VibeCoverImage: Identifiable {
    let id = UUID().uuidString
    let image: UIImage
    let title: String
}
