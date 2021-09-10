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
    
    //For user interactivity
    func getStories() -> AnyPublisher<[Story], Error>
    func getMyStories() -> AnyPublisher<[StoryWithDocID], Error>
}

class StoryService: ObservableObject, StoryServiceProtocol {
    
    private let storage = Storage.storage()
    private let storyMetaService = StoryMetaService.shared
    private let storyContentService = StoryContentService.shared
    
    private var cancellables: [AnyCancellable] = []
    
    @Published private(set) var myStories: [StoryWithDocID] = []
    
    static let shared = StoryService()
    private init() {
        //Fetch myStories
        self.getMyStories()
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
            .flatMap{ _ in self.getMyStories() }
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryService: Failed to post story")
                    promise(.failure(err))
                case .finished:
                    print("StoryService: Successfully posted story")
                    promise(.success(()))
                }
            } receiveValue: { [weak self] myStories in
                self?.myStories = myStories
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
                        if myStories[i].story.meta.postID == storyID {
                            self?.myStories.remove(at: i)
                            break
                        }
                    }
                }
            }
            .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    func getStories() -> AnyPublisher<[Story], Error> {
        //Zip will not work, we need to fetch all story texts
        //  first and then fetch the images one by one and link those
        //  images to the story meta
        //
        //Wait zip may work
        //  We just need to loop through and match the results,
        //  make a Story object using the meta and UIImage
        //
        return Future<[Story], Error> { promise in
            Publishers.Zip(
                self.storyMetaService.getStories(),
                self.storyContentService.getStories()
            )
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryService: Failed to fetch stories")
                    promise(.failure(err))
                case .finished:
                    print("StoryService: Successfully fetched stories")
                }
            } receiveValue: { text, images in
                //match the meta with the image
            }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func getMyStories() -> AnyPublisher<[StoryWithDocID], Error> {
        return Future<[StoryWithDocID], Error> { promise in
            Publishers.Zip(
                self.storyMetaService.getMyStories(),
                self.storyContentService.getMyStories()
            )
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryService: Failed to fetch my stories")
                    promise(.failure(err))
                case .finished:
                    print("StoryService: Successfully fetched my stroies")
                }
            } receiveValue: { text, images in
                
            }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}

//Storage Options

//Option 1
//
// Firebase Storage
// Root -> Stories -> UID -> userStories (name of file: uid + timestamp [i.e., 123__2021__06_12__6_00])
//
// Firestore
// Root -> Stories -> random docID -> (uid, postID, time posted, message, etc.)
//

