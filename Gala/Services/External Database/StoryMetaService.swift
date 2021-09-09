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
    
    func postStory(story: StoryMeta) -> AnyPublisher<Void, Error> {
        let currentUserCore = UserCoreService.shared.currentUserCore!
        return Future<Void, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hash = GFUtils.geoHash(forLocation: location)
            
            //Because we need to query these posts, we need to also add the current UserCore
            self.db.collection("Stories").addDocument(data: [ //(uid, postID, time posted, message, etc.)
                "userCore" : [
                    "uid" : story.uid,
                    "name" : currentUserCore.name,
                    "birthday" : currentUserCore.age,
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
                "postID" : story.postID,
                "timeAndDatePosted" : story.timeAndDatePosted
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
    
    func deleteStory(storyID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            var postDocID: String?
            
            for story in StoryService.shared.myStories {
                if story.story.meta.postID == storyID {
                    postDocID = story.docID
                }
            }
            
            if let docID = postDocID {
                self.db.collection("Stories").document(docID)
                    .delete() { err in
                        if let err = err {
                            print("StoryMetaService: Failed to delete story meta")
                            promise(.failure(err))
                        } else {
                            print("StoryMetaService: Successfully deleted story meta")
                            promise(.success(()))
                        }
                    }
            } else {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getMyStories() -> AnyPublisher<[StoryMetaWithDocID], Error> {
        return Future<[StoryMetaWithDocID], Error> { promise in
            let currrentUID = UserCoreService.shared.currentUserCore?.uid
            self.db.collection("Stories").whereField("uid", isEqualTo: currrentUID!)
                .getDocuments { snapshot, err in
                    if let err = err {
                        print("StoryMetaService: Failed to get MyStroies")
                        promise(.failure(err))
                    }
                    
                    if let snap = snapshot {
                        for document in snap.documents {
                            print("\(document.documentID) => \(document.data())")
                        }
                        
                        let meta: [StoryMetaWithDocID] = []
                        promise(.success(meta))
                        
                    } else {
                        let meta: [StoryMetaWithDocID] = []
                        promise(.success(meta))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func getStories() -> AnyPublisher<[StoryMeta], Error> {
        return Future<[StoryMeta], Error> { promise in
            
        }
        .eraseToAnyPublisher()
    }
}
