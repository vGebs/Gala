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
    
    @Published var stories: [StoryMeta] = []
    
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
            } receiveValue: { stories in
                print(stories)
                self.stories += stories
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
