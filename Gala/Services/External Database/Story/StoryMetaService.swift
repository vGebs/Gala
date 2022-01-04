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
    
    static let shared = StoryMetaService()
    private init() {}
    
    func postStory(postID_date: Date) -> AnyPublisher<Void, Error> {
        if StoryService.shared.postIDs.count == 0{
            return self.pushFirstStory(postID_date)
        } else {
            return self.pushAnotherStory(postID_date)
        }
    }
    
    func deleteStory(storyID: Date) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let currentUser = UserCoreService.shared.currentUserCore!
            if StoryService.shared.postIDs.count == 1 {
                self.db.collection("Stories").document(currentUser.uid)
                    .delete() { err in
                        if let err = err {
                            print("StoryMetaService: Failed to delete post")
                            promise(.failure(err))
                        } else {
                            print("StoryMetaService: Successfully deleted story")
                            promise(.success(()))
                        }
                    }
            } else {
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
            }
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
