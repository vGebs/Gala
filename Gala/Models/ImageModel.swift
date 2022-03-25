//
//  ImageModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

//We need to change this struct to a class and
//we then need to add a method insert and deleteAt
//insert will be an insertionSort algo and
//deleteAt will delete an image at an index

struct ImageModel: Identifiable {
    var image: UIImage
    var id = UUID().uuidString
    var index: Int
}

class ImageContainer: Identifiable {
    var images: [UIImage]?
    var id = UUID().uuidString
    
    func insert(_ img: UIImage) {
        
    }
    
    func delete(at: Int) {
        
    }
    
    func swap(i: Int, with j: Int) {
        
    }
    
    private func insertionSort(){
        
    }
}
