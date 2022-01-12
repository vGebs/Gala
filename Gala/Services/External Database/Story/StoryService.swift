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
    func postStory(postID_date: Date, asset: UIImage) -> AnyPublisher<Void, Error>
    func deleteStory(storyID: Date) -> AnyPublisher<Void, Error>
}

class StoryService: ObservableObject, StoryServiceProtocol {
    
    private let storyMetaService = StoryMetaService.shared
    private let storyContentService = StoryContentService.shared
    
    private var cancellables: [AnyCancellable] = []
    
    //Post IDs are just a timestamp
    //@Published private(set) var postIDs: [Date] = []
    
    static let shared = StoryService()
    private init() {
        //Fetch myStories
        storyMetaService.getMyStories()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryService: Failed to get my recents")
                    print("StoryService-Error: \(err.localizedDescription)")
                case .finished:
                    print("StoryService: Successfully recieved my Stories")
                }
            } receiveValue: { [weak self] myStoryIDs in
                //self?.postIDs = myStoryIDs
            }
            .store(in: &self.cancellables)
    }
    
    func postStory(postID_date: Date, asset: UIImage) -> AnyPublisher<Void, Error> {
                
        return Future<Void, Error> { promise in
            Publishers.Zip(
                self.storyMetaService.postStory(postID_date: postID_date),
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
            } receiveValue: { [weak self] _ in
//                self?.postIDs.append(postID_date)
//                if let postIDs = self?.postIDs {
//                    self?.postIDs = postIDs.removingDuplicates()
//                }
            }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: Date) -> AnyPublisher<Void, Error> {
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
//                for i in 0..<(self?.postIDs.count)!{
//                    if self?.postIDs[i] == storyID {
//                        self?.postIDs.remove(at: i)
//                        print("Removed story from index: \(i)")
//                        print("Story count: \(self?.postIDs.count)")
//                    }
//                }
            }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
