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
        LikesService.shared.observeBasicLikes { [weak self] likes, change in
            switch change {
            case .added:
                for like in likes {
                    ProfileService.shared.getProfile(uid: like.likerUID)
                        .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .failure(let e):
                                print("StoryViewable: failed to fetch userCore and img")
                                print("StoryViewable-err: \(e)")
                            case .finished:
                                print("StoryViewable: Successfully fetched userCore and img")
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
                }
                
            case .removed:
                for like in likes {
                    for i in 0..<(self?.theyLikeMe.count)! {
                        if like.likerUID == self?.theyLikeMe[i].like.likerUID {
                            self?.theyLikeMe.remove(at: i)
                            break
                        }
                    }
                }
            case .modified:
                print("")
            }
        }
    }
}
