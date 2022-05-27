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
    private let currentUser = AuthService.shared.currentUser?.uid

    private var cancellables: [AnyCancellable] = []
    
    static let shared = StoryContentService()
    private init() {}
    
    func postStory(story: UIImage, name: String) -> AnyPublisher<Void, Error> {
        
        let data = story.jpegData(compressionQuality: compressionQuality)!
        let storageRef = storage.reference()
        let storyFolder = "Stories"
        let storyRef = storageRef.child(storyFolder)
        let myStoryRef = storyRef.child(currentUser!)
        let imgFileRef = myStoryRef.child("\(name).png")
        
        return Future<Void, Error> { promise in
            let _ = imgFileRef.putData(data, metadata: nil) { (metaData, error) in
                if let error = error {
                    print("StoryContentService: Failed to add story image")
                    promise(.failure(error))
                } else {
                    return promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: Date) -> AnyPublisher<Void, Error> {
        let storageRef = storage.reference()
        let storyFolder = "Stories"
        let storyRef = storageRef.child(storyFolder)
        let myStoryRef = storyRef.child(currentUser!)
        let imgFileRef = myStoryRef.child("\(storyID).png")
        
        return Future<Void, Error> { promise in
            imgFileRef.delete { err in
                if let err = err {
                    print("StoryContentService: Failed to delete story with id: \(storyID)")
                    print("StoryContentService-err: \(err)")
                } else {
                    print("StoryContentService: Successfully deleted story with id: \(storyID)")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getStory(uid: String, storyID: Date, title: String) -> AnyPublisher<UIImage?, Error> {
        let storageRef = storage.reference()
        let storyFolder = "Stories"
        let storyRef = storageRef.child(storyFolder)
        let myStoryRef = storyRef.child(uid)
        let imgFileRef = myStoryRef.child("\(storyID).png")
        
        return Future<UIImage?, Error> { promise in
            
            if let story = StoryService_CoreData.shared.getStory(with: uid, and: storyID) {
                promise(.success(story.storyImage))
            } else {
                imgFileRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Non lethal fetching error (ImageService): \(error.localizedDescription)")
                    }
                    
                    if let data = data {
                        if let img = UIImage(data: data) {
                            StoryService_CoreData.shared.addStory(post: Post(pid: storyID, uid: uid, title: title, storyImage: img))
                            
                            promise(.success(img))
                        } else {
                            promise(.success(nil))
                        }
                    } else {
                        promise(.success(nil))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
