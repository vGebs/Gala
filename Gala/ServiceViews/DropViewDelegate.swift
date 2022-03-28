//
//  DropViewDelegate.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

//Link for tutorial: https://kavsoft.dev/SwiftUI_2.0/Grid_Reordering/

import SwiftUI

struct DropViewDelegate: DropDelegate{
    var image: ImageModel
    var viewModel: ProfileViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        let fromIndex = viewModel.images.firstIndex { (image) -> Bool in
            return image.id == viewModel.currentImageDrag?.id
        } ?? 0
        
        let toIndex = viewModel.images.firstIndex { (image) -> Bool in
            return image.id == self.image.id
        } ?? 0
        
        if fromIndex != toIndex {
            withAnimation(.default) {
                let fromPage = viewModel.images[fromIndex]
                
                viewModel.images[fromIndex] = viewModel.images[toIndex]

                viewModel.images[toIndex] = fromPage
                
                viewModel.imgsChanged = true 
                
                for i in 0..<viewModel.images.count {
                    viewModel.images[i].index = i + 1
                }
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
