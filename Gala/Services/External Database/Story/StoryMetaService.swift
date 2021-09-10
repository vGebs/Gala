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
                    "uid" : story.userCore.uid,
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
            self.db.collection("Stories").whereField("userCore.uid", isEqualTo: currrentUID!)
                .getDocuments { snap, err in
                    if let err = err {
                        print("StoryMetaService: Failed to get MyStroies")
                        promise(.failure(err))
                    } else {
                        
                        var final: [StoryMetaWithDocID] = []
                        
                        for doc in snap!.documents {
                            print("\(doc.documentID) => \(doc.data())")
                            
                            let fireUserCore = (doc.data()["userCore"] as? [String : Any])!
                            let fireAgePref = (fireUserCore["agePref"] as? [String: Any])!
                            let fireLocation = (fireUserCore["location"] as? [String: Any])!
                            
                            let date = fireUserCore["birthday"] as? String ?? ""
                            let format = DateFormatter()
                            format.dateFormat = "yyyy/MM/dd"
                            
                            let age = format.date(from: date)!
                            
                            let uc = UserCore(
                                uid: fireUserCore["uid"] as? String ?? "",
                                name: fireUserCore["name"] as? String ?? "",
                                age: age,
                                gender: fireUserCore["gender"] as? String ?? "",
                                sexuality: fireUserCore["sexuality"] as? String ?? "",
                                ageMinPref: fireAgePref["min"] as? Int ?? 18,
                                ageMaxPref: fireAgePref["max"] as? Int ?? 99,
                                willingToTravel: fireUserCore["willingToTravel"] as? Int ?? 150,
                                longitude: fireLocation["longitude"] as? Double ?? 0.0,
                                latitude: fireLocation["latitude"] as? Double ?? 0.0
                            )
                            
                            let meta = StoryMeta(
                                postID: doc.data()["postID"] as? String ?? "",
                                timeAndDatePosted: doc.data()["timeAndDatePosted"] as? String ?? "",
                                userCore: uc
                            )
                            
                            let metaWDoc = StoryMetaWithDocID(
                                meta: meta,
                                docID: doc.documentID
                            )
                            print("MetaWDoc: \(metaWDoc)")
                            final.append(metaWDoc)
                        }
                        print("StoryMetaService-getMyStories: \(final)")
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
