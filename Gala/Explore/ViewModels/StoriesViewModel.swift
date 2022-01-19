//
//  StoriesViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import Combine
import SwiftUI

class StoriesViewModel: ObservableObject {
    
    private var storyMetaService = StoryMetaService.shared

    private var cancellables: [AnyCancellable] = []
    
    @Published var stories: [UserPostSimple] = []
    
    init() {
//        storyMetaService.getStories()
//            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                switch completion {
//                case .failure(let err):
//                    print("StoriesViewModel: Failed to fetch stories")
//                    print("StoriesViewModel-err: \(err)")
//                case .finished:
//                    print("StoriesViewModel: Successfully fetched stories")
//                }
//            } receiveValue: { stories in
//                print(stories)
//                self.stories += stories
//            }
//            .store(in: &self.cancellables)
    }
    
    func fetch() {
        storyMetaService.getStories()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoriesViewModel: Failed to fetch stories")
                    print("StoriesViewModel-err: \(err)")
                case .finished:
                    print("StoriesViewModel: Successfully fetched stories")
                }
            } receiveValue: { [weak self] stories in
                print("StoriesViewModel-Stories: \(stories)")
                //Ok, so before we put the stories in an array, we first need to put all the stories from a vibe into the correct bin
                //The array will have to be an array of arrays
                //Each sub array of the main array will be a vibe
                //Each sub array will be sorted based on the post date
                //Based on the first post in each sub array, we will order the arrays such that the first array has the most recent posts
                self?.stories += stories
            }
            .store(in: &self.cancellables)
    }
}

struct StoryModel: Identifiable {
    var id = UUID()
    var story: UIImage
    var name: String
    var userID: String
}

class StoryViewModel: ObservableObject {
    var story: StoryModel
    
    init(_ story: StoryModel){
        self.story = story
    }
}
