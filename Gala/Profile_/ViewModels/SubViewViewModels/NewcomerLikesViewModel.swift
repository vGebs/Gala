//
//  NewcomerLikesViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-03-23.
//

import FirebaseFirestore
import Combine

class NewcomerLikesViewModel: ObservableObject {
    @Published var likes: [LikeWithProfile] = []
    
    private var cancellables: [AnyCancellable] = []
    
    init() { observeNewcomerLikes() }
    
    private func observeNewcomerLikes() {
        LikesService.shared.observeNewcomerLikes { [weak self] likes, change in
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
                                self?.likes.append(newLike)
                            } else if let uc = uc {
                                let newLike = LikeWithProfile(like: like, userCore: uc, profileImg: nil)
                                self?.likes.append(newLike)
                            }
                        }.store(in: &self!.cancellables)
                }
            case .removed:
                for like in likes {
                    for i in 0..<(self?.likes.count)! {
                        if like.likerUID == self?.likes[i].like.likerUID {
                            self?.likes.remove(at: i)
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
