//
//  ActiveSheetEnum.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Foundation

enum ActiveSheet: Identifiable {
    case profileImagePicker
    case showcaseImagePicker
    case profileImageCropper
    case showCaseImageCropper
    
    var id: Int { hashValue }
}
