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
    func postStory(postID_date: Date, vibe: String, img: UIImage, isImage: Bool, caption: Caption?) -> AnyPublisher<Void, Error>
    func deleteStory(storyID: Date, vibe: String) -> AnyPublisher<Void, Error>
}

class StoryService: ObservableObject, StoryServiceProtocol {
    
    private let db = Firestore.firestore()
    
    private let storyMetaService = StoryMetaService.shared
    private let storyContentService = StoryContentService.shared
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = StoryService()
    private init() { }
    
    func postStory(postID_date: Date, vibe: String, img: UIImage, isImage: Bool, caption: Caption?) -> AnyPublisher<Void, Error> {
                
        return Future<Void, Error> { promise in
            Publishers.Zip(
                self.storyMetaService.postStory(postID_date: postID_date, vibe: vibe, isImage: isImage, caption: caption),
                self.storyContentService.postStory(story: img, name: "\(postID_date)")
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
    
    func postStory(postID_date: Date, vibe: String, vidData: Data, isImage: Bool, caption: Caption?) -> AnyPublisher<Void, Error> {
                
        return Future<Void, Error> { promise in
            Publishers.Zip(
                self.storyMetaService.postStory(postID_date: postID_date, vibe: vibe, isImage: isImage, caption: caption),
                self.storyContentService.postStory(story: vidData, name: "\(postID_date)")
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
    
    func observeStories(for uid: String, completion: @escaping (UserPostSimple?, DocumentChangeType) -> Void) {
        db.collection("Stories")
            .document(uid)
            .addSnapshotListener { snapshot, error in
                                
                guard let snap = snapshot else {
                    print("Error fetching stories from uid -> \(uid): \(error!)")
                    return
                }
                
                
                guard let data = snap.data() else {
                    completion(nil, .removed)
                    return
                }
                
                let userCore = data["userCore"] as? [String: Any]
                
                //get birthday and calculate age
                let birthdateString = userCore!["birthday"] as? String ?? ""
                let format = DateFormatter()
                format.dateFormat = "yyyy/MM/dd"
                let birthdate = format.date(from: birthdateString)!
                
                //let agePref = userCore!["agePref"] as? [String: Any]
//                let ageMinPref = agePref!["min"] as? Int ?? 18
//                let ageMaxPref = agePref!["max"] as? Int ?? 99
//
//                let willingToTravel = userCore!["willingToTravel"] as? Int ?? 25
                let location = userCore!["location"] as? [String: Any]
                let lat = location!["latitude"] as? Double ?? 0
                let lng = location!["longitude"] as? Double ?? 0
                
                let id = userCore!["uid"] as? String ?? ""
                let name = userCore!["name"] as? String ?? ""

                var posts: [Post] = []
                if let inComingPosts = data["posts"] as? [[String: Any]] {
                    for post in inComingPosts {
                        let title = post["title"] as? String ?? ""
                        let pid = post["id"] as? Timestamp
                        
                        let pidFinal = pid?.dateValue()
                                                            
                        if let pidF = pidFinal {
                            let newPost = Post(pid: pidF, uid: id, title: title)
                            posts.append(newPost)
                        }
                    }
                }
                
                let uSimp = UserPostSimple(posts: posts, name: name, uid: id, birthdate: birthdate, coordinates: Coordinate(lat: lat, lng: lng))
                
                completion(uSimp, .added)
            }
    }
}
