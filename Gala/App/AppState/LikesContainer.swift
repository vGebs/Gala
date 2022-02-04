//
//  LikesContainer.swift
//  Gala
//
//  Created by Vaughn on 2022-02-03.
//

import Combine
import Foundation
import FirebaseFirestore

class LikesContainer: ObservableObject {
    static let shared = LikesContainer()
    
    private(set) var iLiked: [StoryLike] = []
    
    private var cancellables: [AnyCancellable] = []
    
    private let db = Firestore.firestore()
    
    private init() {
        print("LikesContainer: initialized")
        observeLikes()
    }
    
    func observeLikes() {
        db.collection("Likes")
            .whereField("likerUID", isEqualTo: AuthService.shared.currentUser!.uid)
            .addSnapshotListener { documentSnapshot, error in
                guard let documents = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }

                documentSnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        
                        let birthdateOfLiker = data["birthdayOfLiker"] as? String ?? ""
                        let likedUID = data["likedUID"] as? String ?? ""
                        let likerUID = data["likerUID"] as? String ?? ""
                        let nameOfLiker = data["nameOfLiker"] as? String ?? ""
                        
                        let postID = data["postID"] as? Timestamp
                        let dateOfLike = data["dateOfLike"] as? Timestamp
                        
                        if let d = dateOfLike {
                            if let p = postID {
                                let dateOfLikeFinal = d.dateValue()
                                let postIDFinal = p.dateValue()
                                
                                let like = Like(
                                    dateOfLike: dateOfLikeFinal,
                                    likerUID: likerUID,
                                    likedUID: likedUID,
                                    nameOfLiker: nameOfLiker,
                                    birthdayOfLiker: birthdateOfLiker,
                                    storyID: postIDFinal
                                )
                                
                                let newStoryLike = StoryLike(like: like, docID: change.document.documentID)
                                self.iLiked.append(newStoryLike)
                            } else {
                                let dateOfLikeFinal = d.dateValue()
                                
                                let like = Like(
                                    dateOfLike: dateOfLikeFinal,
                                    likerUID: likerUID,
                                    likedUID: likedUID,
                                    nameOfLiker: nameOfLiker,
                                    birthdayOfLiker: birthdateOfLiker,
                                    storyID: nil
                                )
                                
                                let newStoryLike = StoryLike(like: like, docID: change.document.documentID)
                                print("NewStoryLike: \(newStoryLike)")
                                self.iLiked.append(newStoryLike)
                            }
                        }
                    }
                })
            }
    }
    
    private func fetchLikes() {
        LikesService.shared.getPeopleILiked()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("LikesContainer: Failed to fetch the people i like")
                    print("LikesContainer-err: \(err)")
                case .finished:
                    print("LikesContainer: Successfully fetched people i like")
                }
            } receiveValue: { [weak self] likes in
                self?.iLiked = likes
            }
            .store(in: &cancellables)
    }
}
