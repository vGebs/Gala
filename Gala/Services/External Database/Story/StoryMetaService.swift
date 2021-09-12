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
    
    //Some major changes:
    //  What we're going to do:
    //      - Going to fetch stories (meta) and then push that object into another object.
    //          When the new object is initialized, it will take the storyID's and
    //          And fetch the content, similar to the RecentlyJoined/SmallUserViewModel
    //      - This new object will hold the StoryMeta and an array of images/videos/assets
    //
    //  So when posting a story we need to:
    //      1. Check to see if the current myStories array is empty
    //          a) If empty, we push a brand new story
    //          b) If not empty, we add the new stories timestamp to the storyID's array
    //      2. Everytime we make a post we add it to the current Story Array (after success confirmation).
    //          We will not need to query the db(like we're doing rn) because we already have all the info we need.
    //          i.e., we already have the docID which is the currentUser ID.
    //          Therefore we no longer need StoryMetaWDocID model
    //
    //  PS. -> The content (image/video) will be placed in firebase storage in location:
    //              Stories -> uid folder -> timestamp for asset (timestamp will be the storyID)
    //
    //  Aside:
    //      We will likely not need the functions 'getStories' & 'getMyStories' from StoryServie
    //          anymore. Because in order to get the images we first need the meta, which will be
    //          pushed to the new object we have not yet made (similar to Recentlyjoined/SmallUserViewModel).
    //
    //      The only functions in StoryService will be 'postStory' & 'deleteStory'.
    //
    //  Question:
    //      Should we keep the 'myStories' array in StoryMetaService or StoryService?
    //
    
    func postStory(story: StoryMeta) -> AnyPublisher<Void, Error> {
        if StoryService.shared.myStories.count == 0 {
            return self.pushFirstStory(story)
        } else {
            return self.pushAnotherStory(story)
        }
    }
    
    func pushFirstStory(_ story: StoryMeta) -> AnyPublisher<Void, Error> {
        let currentUserCore = UserCoreService.shared.currentUserCore!
        return Future<Void, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hash = GFUtils.geoHash(forLocation: location)
            
            //Because we need to query these posts, we need to also add the current UserCore
            self.db.collection("Stories").document(currentUserCore.uid).setData([
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
                "postIDs" : [story.postID_timeAndDatePosted]
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
    
    func pushAnotherStory(_ story: StoryMeta) -> AnyPublisher<Void, Error> {
        let currentUserCore = UserCoreService.shared.currentUserCore!
        return Future<Void, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hash = GFUtils.geoHash(forLocation: location)
            
            self.db.collection("Stories").document(currentUserCore.uid)
                .updateData([
                    "postIDs" : FieldValue.arrayUnion([story.postID_timeAndDatePosted]),
                    "userCore.location.geoHash" : hash,
                    "userCore.location.latitude" : lat,
                    "userCore.location.longitude" : long
                ])
        }.eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            var postDocID: String?
            
            for story in StoryService.shared.myStories {
                if story.postID_timeAndDatePosted == storyID {
                    postDocID = story.postID_timeAndDatePosted
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
    
    func getMyStories() -> AnyPublisher<[StoryMeta], Error> {
        return Future<[StoryMeta], Error> { promise in
            let currrentUID = UserCoreService.shared.currentUserCore?.uid
            self.db.collection("Stories").whereField("userCore.uid", isEqualTo: currrentUID!)
                .getDocuments { snap, err in
                    if let err = err {
                        print("StoryMetaService: Failed to get MyStroies")
                        promise(.failure(err))
                    } else {
                        
                        var final: [StoryMeta] = []
                        
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
                                postID_timeAndDatePosted: doc.data()["postIDs"] as? String ?? "",
                                userCore: uc
                            )
                            
                            final.append(meta)
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
