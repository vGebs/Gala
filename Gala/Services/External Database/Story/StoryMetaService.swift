//
//  StoryTextService.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import Combine
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import GeoFire

class StoryMetaService: ObservableObject {
    
    private let db = Firestore.firestore()
    
    private var currentUserCore = UserCoreService.shared.currentUserCore!
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = StoryMetaService()
    private init() {}
    
    func postStory(postID_date: Date, vibe: String) -> AnyPublisher<Void, Error> {
        //Fetch stories from db, check how many there are
        // If there isnt any, make a new post
        // If there is some, update the doc
        
        //If stories.count == 0 -> pushFirstStory
        // else -> pushAnotherStory
        self.getMyStories()
            .flatMap { stories in
                self.pushStory(postID_date, stories, vibe)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: Date, vibe: String) -> AnyPublisher<Void, Error> {
        //If count == 1 -> deleteLastStory
        // otherwise -> deleteOneOfManyStories
        self.getMyStories()
            .flatMap { stories in
                self.deleteStory(storyID, stories, vibe)
            }
            .eraseToAnyPublisher()
    }
    
    func getMyStories() -> AnyPublisher<[StoryWithVibe], Error> {
        let currrentUser = UserCoreService.shared.currentUserCore!
        return Future<[StoryWithVibe], Error>{ promise in
            self.db.collection("Stories").document(currrentUser.uid)
                .getDocument { snap, err in
                    if let err = err {
                        print("StoryMetaService: Failed to fetch stories")
                        promise(.failure(err))
                    } else if let snap = snap {
                        var final: [StoryWithVibe] = []
                        if let posts = snap.data()?["posts"] as? [[String: Any]] {
                            for i in 0..<posts.count {
                                
                                let id = posts[i]["id"] as? Timestamp
                                let idFinal = id?.dateValue()
                                
                                let title = posts[i]["title"] as? String
                                
                                if let idd = idFinal, let title = title {
                                    let storyWithVibe = StoryWithVibe(pid: idd, title: title)
                                    //print(storyWithVibe)
                                    final.append(storyWithVibe)
                                }
                            }
                        }
                        promise(.success(final))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func getStories() -> AnyPublisher<[StoryMeta], Error> {
        return Future<[StoryMeta], Error> { promise in
            
        }
        .eraseToAnyPublisher()
    }
}

extension StoryMetaService {
    
    private func pushStory(_ postID: Date, _ stories: [StoryWithVibe], _ vibe: String) ->AnyPublisher<Void, Error> {
        if stories.count == 0 {
            return self.pushFirstStory(postID, vibe)
        } else {
            return self.pushAnotherStory(postID, vibe)
        }
    }
    
    private func pushFirstStory(_ postID_date: Date, _ vibe: String) -> AnyPublisher<Void, Error> {
        let currentUserCore = UserCoreService.shared.currentUserCore!
        return Future<Void, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hash = GFUtils.geoHash(forLocation: location)
            
            //Because we need to query these posts, we need to also add the current UserCore
            self.db.collection("Stories").document(currentUserCore.uid).setData([
                "userCore" : [
                    "uid" : currentUserCore.uid,
                    "name" : currentUserCore.name,
                    "birthday" : currentUserCore.age.formatDate(),
                    "gender" : currentUserCore.gender,
                    "sexuality" : currentUserCore.sexuality,
                    "agePref" : [
                        "min" : currentUserCore.ageMinPref,
                        "max" : currentUserCore.ageMaxPref,
                    ],
                    "willingToTravel" : currentUserCore.willingToTravel,
                    "location" : [
                        "geoHash" : hash,
                        "longitude" : currentUserCore.longitude,
                        "latitude" : currentUserCore.latitude,
                    ]
                ],
                "posts" : [
                    [
                        "id": postID_date,
                        "title": vibe
                    ]
                ]
            ]) { err in
                if let err = err {
                    print("StoryMetaService: Failed to post story meta")
                    promise(.failure(err))
                } else {
                    print("StoryMetaService: Successfully posted story meta")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func pushAnotherStory(_ postID_date: Date, _ vibe: String) -> AnyPublisher<Void, Error> {
        let currentUserCore = UserCoreService.shared.currentUserCore!
        return Future<Void, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hash = GFUtils.geoHash(forLocation: location)
            
            self.db.collection("Stories").document(currentUserCore.uid)
                .updateData([
                    "posts" : FieldValue.arrayUnion(
                        [
                            [
                                "id": postID_date,
                                "title": vibe
                            ]
                        ]
                    ),
                    "userCore.location.geoHash" : hash,
                    "userCore.location.latitude" : lat,
                    "userCore.location.longitude" : long
                ]) { err in
                    if let err = err {
                        print("StoryMetaService: Failed to push another story w/ id: \(postID_date)")
                        promise(.failure(err))
                    } else {
                        print("StoryMetaService: Successfully pushed another story w/ id: \(postID_date)")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
}

extension StoryMetaService {
    
    private func deleteStory(_ postID: Date, _ stories: [StoryWithVibe], _ vibe: String) -> AnyPublisher<Void, Error> {
        if stories.count == 1 {
            return self.deleteLastStory()
        } else {
            return self.deleteOneOfManyStories(storyID: postID, vibe: vibe)
        }
    }
    
    private func deleteLastStory() -> AnyPublisher<Void, Error> {
        let currentUser = UserCoreService.shared.currentUserCore!
        
        return Future<Void, Error>{ promise in
            self.db.collection("Stories").document(currentUser.uid)
                .delete() { err in
                    if let err = err {
                        print("StoryMetaService: Failed to delete last post")
                        promise(.failure(err))
                    } else {
                        print("StoryMetaService: Successfully deleted last story")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    private func deleteOneOfManyStories(storyID: Date, vibe: String) -> AnyPublisher<Void, Error> {
        let currentUser = UserCoreService.shared.currentUserCore!

        return Future<Void, Error> { promise in
            self.db.collection("Stories").document(currentUser.uid)
                .updateData([
                    "posts" : FieldValue.arrayRemove(
                        [
                            [
                                "id": storyID,
                                "title" : vibe
                            ]
                        ]
                    )
                ]) { err in
                    if let err = err {
                        print("StoryMetaService: Failed to delete Story")
                        promise(.failure(err))
                    } else {
                        print("StoryMetaService: Successfully deleted story")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
}
