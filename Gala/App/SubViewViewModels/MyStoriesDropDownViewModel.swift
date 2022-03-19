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
    @Published var stories: [StoryViewable] = []
    private var cancellables: [AnyCancellable] = []
    
    init() {
        //Fetch all new stories
        
        //fetchStories()
        //Fetch Likes for each story (need the stories first before we can get likes)
        observeStories()
    }
    
    private func observeStories() {
        StoryMetaService.shared.observeMyStories { [weak self] stories in
            self?.stories = []
            for post in stories {
                let newStory = StoryViewable(pid: post.pid, title: post.title)
                self?.stories.insert(newStory, at: 0)
            }
        }
    }
    
    private func fetchStories() {
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
            } receiveValue: { [weak self] stories in
                for post in stories {
                    let newStory = StoryViewable(pid: post.pid, title: post.title)
                    self?.stories.insert(newStory, at: 0)
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteStory(storyID: Date, vibe: String) {
        StoryService.shared.deleteStory(storyID: storyID, vibe: vibe)
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
                    if self?.stories[i].pid == storyID {
                        self?.stories.remove(at: i)
                        break
                    }
                }
            }.store(in: &cancellables)
    }
}
