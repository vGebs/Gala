//
//  StoryImageService.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import Combine
import SwiftUI
import FirebaseStorage
import FirebaseFirestore

class StoryContentService: ObservableObject {
    
    private let storage = Storage.storage()
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = StoryContentService()
    private init() {}
    
    func postStory(story: UIImage) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
    
    func getStories() -> AnyPublisher<[UIImage], Error> {
        return Future<[UIImage], Error> { promise in
            
        }.eraseToAnyPublisher()
    }
    
    func getMyStories() -> AnyPublisher<[UIImage], Error> {
        return Future<[UIImage], Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
