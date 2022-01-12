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
    
    func postStory(postID_date: Date) -> AnyPublisher<Void, Error> {
        //Fetch stories from db, check how many there are
        // If there isnt any, make a new post
        // If there is some, update the doc
        
        //If stories.count == 0 -> pushFirstStory
        // else -> pushAnotherStory
        self.getMyStories()
            .flatMap { stories in
                self.pushStory(postID_date, stories)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: Date) -> AnyPublisher<Void, Error> {
        //If count == 1 -> deleteLastStory
        // otherwise -> deleteOneOfManyStories
        self.getMyStories()
            .flatMap { stories in
                self.deleteStory(storyID, stories)
            }
            .eraseToAnyPublisher()
    }
    
    func getMyStories() -> AnyPublisher<[Date], Error> {
        let currrentUser = UserCoreService.shared.currentUserCore!
        return Future<[Date], Error>{ promise in
            self.db.collection("Stories").document(currrentUser.uid)
                .getDocument { snap, err in
                    if let err = err {
                        print("StoryMetaService: Failed to fetch stories")
                        promise(.failure(err))
                    } else if let snap = snap {
                        var final: [Date] = []
                        if let ids = snap.data()?["postIDs"] as? [Any] {
                            for i in 0..<ids.count {
                                let id = ids[i] as? Timestamp
                                let idd = id?.dateValue()
                                if let id_ = idd {
                                    final.append(id_)
                                }
                            }
                        }
                        print("PostIDs: \(final)")
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
    
    private func pushStory(_ postID: Date, _ stories: [Date]) ->AnyPublisher<Void, Error> {
        if stories.count == 0 {
            return self.pushFirstStory(postID)
        } else {
            return self.pushAnotherStory(postID)
        }
    }
    
    private func pushFirstStory(_ postID_date: Date) -> AnyPublisher<Void, Error> {
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
                "postIDs" : [postID_date]
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
    
    private func pushAnotherStory(_ postID_date: Date) -> AnyPublisher<Void, Error> {
        let currentUserCore = UserCoreService.shared.currentUserCore!
        return Future<Void, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hash = GFUtils.geoHash(forLocation: location)
            
            self.db.collection("Stories").document(currentUserCore.uid)
                .updateData([
                    "postIDs" : FieldValue.arrayUnion([postID_date]),
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
    
    private func deleteStory(_ postID: Date, _ stories: [Date]) -> AnyPublisher<Void, Error> {
        if stories.count == 1 {
            return self.deleteLastStory()
        } else {
            return self.deleteOneOfManyStories(storyID: postID)
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
    
    private func deleteOneOfManyStories(storyID: Date) -> AnyPublisher<Void, Error> {
        let currentUser = UserCoreService.shared.currentUserCore!

        return Future<Void, Error> { promise in
            self.db.collection("Stories").document(currentUser.uid)
                .updateData([
                    "postIDs" : FieldValue.arrayRemove([storyID])
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
