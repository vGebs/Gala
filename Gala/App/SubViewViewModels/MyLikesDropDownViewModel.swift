//
//  MyLikesDropDownViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-01-12.
//

import Foundation
import SwiftUI
import Combine

class MyLikesDropDownViewModel: ObservableObject {
    @Published var image: UIImage?

    private var cancellables: [AnyCancellable] = []
    
    init(story: StoryAndLikes) {
        let currentUID = AuthService.shared.currentUser?.uid

        StoryContentService.shared.getStory(uid: currentUID!, storyID: story.storyID)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("MyLikesDropDown: Failed to fetch story asset")
                    print("MyLikesDropDown-err: \(err)")
                case .finished:
                    print("MyLikesDropDown: Successfully fetched story asset")
                }
            } receiveValue: {[weak self] image in
                if let img = image {
                    self?.image = img
                }
            }
            .store(in: &self.cancellables)
    }
}
