//
//  StoryService.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import Combine
import SwiftUI
import FirebaseFirestore

//This protocol will have to be expanded once video is working
protocol StoryServiceProtocol {
    //User actions
    func postStory(postID_date: Date, vibe: String, asset: UIImage) -> AnyPublisher<Void, Error>
    func deleteStory(storyID: Date, vibe: String) -> AnyPublisher<Void, Error>
}

class StoryService: ObservableObject, StoryServiceProtocol {
    
    private let storyMetaService = StoryMetaService.shared
    private let storyContentService = StoryContentService.shared
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = StoryService()
    private init() { }
    
    func postStory(postID_date: Date, vibe: String, asset: UIImage) -> AnyPublisher<Void, Error> {
                
        return Future<Void, Error> { promise in
            Publishers.Zip(
                self.storyMetaService.postStory(postID_date: postID_date, vibe: vibe),
                self.storyContentService.postStory(story: asset, name: "\(postID_date)")
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
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: Date, vibe: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Publishers.Zip(
                self.storyMetaService.deleteStory(storyID: storyID, vibe: vibe),
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
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}
