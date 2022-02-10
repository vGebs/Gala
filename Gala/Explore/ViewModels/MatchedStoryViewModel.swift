//
//  MatchedStoryViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-02-09.
//

import Combine
import Foundation
import UIKit

class MatchedStoryViewModel: ObservableObject {
    @Published var img: UIImage?
    private var cancellables: [AnyCancellable] = []
    
    init(story: UserPostSimple){
        StoryContentService.shared.getStory(uid: story.uid, storyID: story.posts[0].pid)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("MatchedStoryViewModel: Failed to fetch story image")
                    print("MatchedStoryViewModel-err: \(err)")
                case .finished:
                    print("MatchedViewModel: Successfully fetched story image")
                }
            } receiveValue: { [weak self] post in
                if let img = post {
                    self?.img = img
                }
            }
            .store(in: &cancellables)
    }
}
