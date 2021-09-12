//
//  StoryService.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

//This protocol will have to be expanded once video is working
protocol StoryServiceProtocol {
    //User actions
    func postStory(story: Story) -> AnyPublisher<Void, Error>
    func deleteStory(storyID: String) -> AnyPublisher<Void, Error>
}

class StoryService: ObservableObject, StoryServiceProtocol {
    
    private let storage = Storage.storage()
    private let storyMetaService = StoryMetaService.shared
    private let storyContentService = StoryContentService.shared
    
    private var cancellables: [AnyCancellable] = []
    
    @Published private(set) var myStories: [StoryMeta] = []
    
    static let shared = StoryService()
    private init() {
        //Fetch myStories
        storyMetaService.getMyStories()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryService: Failed to get my recents")
                    print("StoryService-Error: \(err.localizedDescription)")
                case .finished:
                    print("StoryService: Successfully recieved my Stories")
                }
            } receiveValue: { [weak self] myStories in
                self?.myStories = myStories
            }
            .store(in: &self.cancellables)
    }
    
    func postStory(story: Story) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Publishers.Zip(
                self.storyMetaService.postStory(story: story.meta),
                self.storyContentService.postStory(story: story.image)
            )
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryService: Failed to post story")
                    promise(.failure(err))
                case .finished:
                    print("StoryService: Successfully posted story")
                    promise(.success(()))
                }
            } receiveValue: { [weak self] _ in
                self?.myStories.append(story.meta)
            }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Publishers.Zip(
                self.storyMetaService.deleteStory(storyID: storyID),
                self.storyContentService.deleteStory(storyID: storyID)
            )
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryService: Failed to delete story with ID: \(storyID)")
                    promise(.failure(err))
                case .finished:
                    print("StoryService: Successfully deleted story with ID: \(storyID)")
                    promise(.success(()))
                }
            } receiveValue: { [weak self] _, _ in
                if let myStories = self?.myStories {
                    for i in 0..<myStories.count {
                        if myStories[i].postID_timeAndDatePosted == storyID {
                            self?.myStories.remove(at: i)
                            break
                        }
                    }
                }
            }
            .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
}
