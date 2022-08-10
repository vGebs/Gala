//
//  NewcomerLikesViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-03-23.
//

import FirebaseFirestore
import Combine

class BasicLikesViewModel: ObservableObject {
    @Published var theyLikeMe: [LikeWithProfile] = []
    
    private var cancellables: [AnyCancellable] = []
    
    init() { observeNewcomerLikes() }
    
    private func observeNewcomerLikes() {
        LikesService.shared.observeBasicLikes { [weak self] likes in
            
            for like in likes {
                if let change = like.changeType {
                    switch change {
                    case .added:
                        ProfileService.shared.getProfile(uid: like.likerUID)
                            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                            .receive(on: DispatchQueue.main)
                            .sink { completion in
                                switch completion {
                                case .failure(let e):
                                    print("BasicLikesViewModel: failed to fetch userCore and img")
                                    print("BasicLikesViewModel-err: \(e)")
                                case .finished:
                                    print("BasicLikesViewModel: Successfully fetched userCore and img")
                                }
                            } receiveValue: { [weak self] uc, img in
                                if let uc = uc, let img = img {
                                    let newLike = LikeWithProfile(like: like, userCore: uc, profileImg: img)
                                    self?.theyLikeMe.append(newLike)
                                } else if let uc = uc {
                                    let newLike = LikeWithProfile(like: like, userCore: uc, profileImg: nil)
                                    self?.theyLikeMe.append(newLike)
                                }
                            }.store(in: &self!.cancellables)
                    case .modified:
                        if let i = self?.theyLikeMe.firstIndex(where: { $0.like.likerUID == like.likerUID }) {
                            self?.theyLikeMe[i].like = like
                            print("BasicLikesViewModel: modified like")
                        }
                        
                    case .removed:
                        self?.theyLikeMe = self!.theyLikeMe.filter { $0.like.likerUID != like.likerUID }
                        print("BasicLikesViewModel: removed like")
                    }
                }
            }
        }
    }
}
