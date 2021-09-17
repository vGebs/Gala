//
//  LikesService.swift
//  Gala
//
//  Created by Vaughn on 2021-09-03.
//

import Combine
import FirebaseFirestore

protocol LikesServiceProtocol {
    func likeUser(uid: String) -> AnyPublisher<Void, Error>
    func unLikeUser(uid: String) -> AnyPublisher<Void, Error>
    
    //Premium version
    func getPeopleThatLikeMe() -> AnyPublisher<[Like], Error>
    
    //Temporary (will have trigger on backend that adds mutual likes to matches collection)
    func getMyMatches() -> AnyPublisher<[Like], Error>
}

class LikesService: LikesServiceProtocol {
    
    private let db = Firestore.firestore()
    private var currentUserCore = UserCoreService.shared.currentUserCore!
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = LikesService()

    private init() {}
    
    func likeUser(uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection("Likes").addDocument(data: [
                "dateOfLike" : Date(),
                "likerUID" : self.currentUserCore.uid,
                "likedUID" : uid,
                "nameOfLiker" : self.currentUserCore.name,
                "birthdayOfLiker" : self.currentUserCore.age.formatDate()
            ]) { err in
                if let err = err {
                    print("LikesService: Failed to like user with id: \(uid)")
                    print("LikesService-Error: \(err.localizedDescription)")
                    promise(.failure(err))
                } else {
                    print("LikesService: Successfully likes user with id: \(uid)")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func unLikeUser(uid: String) -> AnyPublisher<Void, Error> {
        self.getPeopleILiked().flatMap { users in
            self.unLikeUser_(uid: uid, inComingLikes: users)
        }
        .eraseToAnyPublisher()
    }
    
    private func unLikeUser_(uid: String, inComingLikes: [InComingLike]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            for like in inComingLikes {
                if like.like.likedUID == uid {
                    self.db.collection("Likes").document(like.docID)
                        .delete() { err in
                            if let err = err {
                                print("LikesService-unLikeUser_: error unliking user")
                                promise(.failure(err))
                            } else {
                                print("LikesService: Successfully unLiked User")
                                promise(.success(()))
                            }
                        }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    //This function returns all users that have liked the current user
    func getPeopleThatLikeMe() -> AnyPublisher<[Like], Error> {
        return Future<[Like], Error> { promise in
            self.db.collection("Likes")
                .whereField("likedUID", isEqualTo: self.currentUserCore.uid)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("LikesService: failed to get Likes")
                        print("LikesService-Error: \(error.localizedDescription)")
                        promise(.failure(error))
                    } else {
                        for doc in snapshot!.documents {
                            print("\(doc.documentID) => \(doc.data())")
                        }
                        let likes: [Like] = []
                        promise(.success(likes))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func getPeopleILiked() -> AnyPublisher<[InComingLike], Error> {
        return Future<[InComingLike], Error> { promise in
            self.db.collection("Likes")
                .whereField("likerUID", isEqualTo: self.currentUserCore.uid)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("LikesService: failed to get Likes")
                        print("LikesService-Error: \(error.localizedDescription)")
                        promise(.failure(error))
                    } else {
                        var inComingLikes: [InComingLike] = []
                        
                        for doc in snapshot!.documents {
                            let date = doc.data()["dateOfLike"] as? Timestamp
                            let d = date?.dateValue()
                            
                            let like = Like(
                                dateOfLike: d!,
                                likerUID: doc.data()["likerUID"] as? String ?? "",
                                likedUID: doc.data()["likedUID"] as? String ?? "",
                                nameOfLiker: doc.data()["nameOfLiker"] as? String ?? "",
                                birthdayOfLiker: doc.data()["birthdayOfLiker"] as? String ?? ""
                            )
                            
                            let inComing = InComingLike(
                                like: like,
                                docID: doc.documentID
                            )
                            
                            inComingLikes.append(inComing)
                            
                            print("InComingLikes: \(inComing)")
                        }
                        promise(.success(inComingLikes))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    //Temporary function
    func getMyMatches() -> AnyPublisher<[Like], Error> {
        return Future<[Like], Error> { promise in
            Publishers.Zip(
                self.getPeopleThatLikeMe(),
                self.getPeopleILiked()
            )
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("LikesService: Failed to get matches")
                    print("LikesService-Error: \(error)")
                    promise(.failure(error))
                case .finished:
                    print("LikesService: Successfully recieved macthes")
                }
            } receiveValue: { likedMe, iLiked in
                var matches: [Like] = []
                for i in 0..<likedMe.count {
                    for j in 0..<iLiked.count {
                        if likedMe[i].likerUID == iLiked[j].like.likedUID {
                            matches.append(likedMe[i])
                        }
                    }
                }
                promise(.success(matches))
            }
            .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}


//NOTE: These solutions do not take into account loading user images
// ASIDE: we are going to assume there is:
//          1,000,000 users
//          user makes 300 likes
//          user has 100 Matches
//
//Remember that Firestore uses binary search to query fields
// binary search = log **base 2** (n)
//

// Option 1:
//UserCore -> iLikeThem
//         -> theyLikeMe
//When a user likes another user, they place a like in their own iLikeThem Collection               **2 writes**
//  and also a like in the other user's theyLikeMe Collection
//
//There will be a cloud trigger that is called everytime a like is placed in iLikeThem              **2 reads**
//  or theyLikeMe
//                      log(300) (ran in parallel)
//
//If iLikeThem and theyLikeMe, the trigger will delete the like from iLikeThem and theyLikeMe       **4 deletes**
//  from both of the users collections and add each as a match in the UserCore -> Matches list      **1 write**
//
//The user will then have to query matches and will get the required info about that match          **1 read**
//                  log(100)
//                                                                                                ---------------
//                                                                                                **10 operations**
//
//                                                                      log(300) + log(100) = 8 + 7 = 15 ops

// Option 2:
//Likes (in root)
//
//Like Object:
//    var likerUID: String
//    var likedUID: String
//
//    var nameOfLiker: String
//    var birthdayOfLiker: String
//
//When a user is liked, they create one entry into the Likes collection                             **1 write**
//
//Everytime there is a like, a cloud function is triggered that checks to see
//  if there is a match in the documents                                                            **2 reads**
//                  log(1,000,000 * 300) (ran in parallel)
//If so, both likes are deleted and a match is made in the matches collection                       **2 deletes**
//                                                                                                  **1 write**
//
//The user will then make a query with 'arrayContains' to get match info                            **1 read**
//                  log(100,000,000)
//The User will then have to make another query to get their matches name,                          **1 read**
//  bday, and location                                                                          ________________
//          log(1)
//                                                                                             **8 operations total**
//
//                                           log(1,000,000 * 300) + log(1,000,000 * 100) = 28 + 27 + 1 = 56 ops

// Option 3:
//This solution is very similar to option 2 but differs in where matches are placed
//Likes (in root)
//
//Like Object:
//    var likerUID: String
//    var likedUID: String
//
//    var nameOfLiker: String
//    var birthdayOfLiker: String
//
//When a user is liked, they create one entry into the Likes collection                             **1 write**
//
//Everytime there is a like, a cloud function is triggered that checks to see
//  if there is a match in the documents                                                            **2 reads**
//                  log(1,000,000 * 300) (ran in parallel)
//If so, both likes are deleted and a match is made in each of the users matches collection         **2 deletes**
//                                                                                                  **2 write**
//The match added to the users Match collection will contain all info needed for a simple view      **1 read**
//
//                                                                                                ----------------
//                                                                                                **8 operations**
//
//                                                                  log(1,000,000 * 300)= 28 ops
//
//Pros:
// only 8 operations
// Fast matches read time
//
//Cons:
//  Have to look through all likes
//
//Conculsion: This is the best option
