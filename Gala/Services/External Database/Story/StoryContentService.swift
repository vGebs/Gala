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
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: Date) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func getStory(id: Date) -> AnyPublisher<UIImage, Error> {
        return Future<UIImage, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
