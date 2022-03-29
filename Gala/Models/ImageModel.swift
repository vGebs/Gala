//
//  ImageModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ImageModel: Identifiable {
    var image: UIImage
    var id = UUID().uuidString
    var index: Int
}
