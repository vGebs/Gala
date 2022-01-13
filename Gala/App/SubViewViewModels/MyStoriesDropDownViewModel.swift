//
//  MyStoriesDropDownViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-01-07.
//

import Foundation
import SwiftUI
import Combine

class MyStoriesDropDownViewModel: ObservableObject {
    @Published var stories: [StoryAndLikes] = []
    private var cancellables: [AnyCancellable] = []
    
    init() {
        //Fetch all new stories
        StoryMetaService.shared.getMyStories()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("MyStoriesDropDownViewModel: Failed to fetch my stories")
                    print("MyStoriesDropDownViewModel-error: \(err)")
                case .finished:
                    print("MyStoriesDropDownViewModel: Successfully fetched my stories")
                }
            } receiveValue: { [weak self] postIDs in
                print("PostIDs: \(postIDs)")
                //self?.stories = postIDs
                for post in postIDs {
                    let newStory = StoryAndLikes(storyID: post, likes: [])
                    self?.stories.insert(newStory, at: 0)
                }
            }
            .store(in: &cancellables)
        //Fetch Likes for each story (need the stories first before we can get likes)
    }
    
    func deleteStory(storyID: Date) {
        StoryService.shared.deleteStory(storyID: storyID)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("MyStoriesDropDownViewModel: Failed to delete post")
                    print("MyStoriesDropDownViewModel-error: \(err)")
                case .finished:
                    print("MyStoriesDropDownViewModel: Successfully deleted post")
                }
            } receiveValue: { [weak self] _ in
                for i in 0..<(self?.stories.count)!{
                    if self?.stories[i].storyID == storyID {
                        self?.stories.remove(at: i)
                        break
                    }
                }
            }.store(in: &cancellables)
    }
}
