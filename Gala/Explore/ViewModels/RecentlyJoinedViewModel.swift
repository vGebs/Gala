//
//  RecentlyJoinedViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-04.
//

import Foundation
import Combine
import SwiftUI

class RecentlyJoinedViewModel: ObservableObject {
    
    private var recents = RecentlyJoinedUserService.shared
    private var likeService = LikesService.shared
    
    @Published private(set) var users: [SmallUserViewModel] = []
    
    private var cancellables: [AnyCancellable] = []
    
    init() {
        Publishers.Zip(
            recents.getRecents(),
            likeService.getPeopleILiked()
        )
        .subscribe(on: DispatchQueue.global(qos: .userInteractive))
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .failure(let err):
                print("ExploreViewModel: failed to load recents")
                print("ExploreViewModel-Error: \(err)")
            case .finished:
                print("ExploreViewModel: Got recents")
            }
        } receiveValue: { [weak self] recents, iLiked in
            var final: [SmallUserViewModel] = []
            if let recents = recents {
                if iLiked.count > 0 {
                    let final: [SmallUserViewModel] = recents
                        .enumerated()
                        .filter { user in
                            var dontAdd = false
                            for i in 0..<iLiked.count {
                                if user.element.uid == iLiked[i].like.likedUID {
                                    dontAdd = true
                                }
                            }
                            
                            return dontAdd == false
                        }
                        .map { SmallUserViewModel(profile: $0.element) }
                    self?.users = final
                } else {
                    for i in 0..<recents.count {
                        let temp = SmallUserViewModel(profile: recents[i])
                        final.append(temp)
                    }
                    self?.users = final
                }
            } else {
                print("ExploreViewModel recents: nil")
            }
        }
        .store(in: &self.cancellables)
    }
    
    func likeUser(with uid: String) {
        LikesService.shared.likeUser(uid: uid)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("SmallUserViewModel: Failed to like user")
                    print("SmallUserViewModel-Error: \(error.localizedDescription)")
                
                case .finished:
                    print("SmallUserViewModel: Liked user with id: \(uid)")
                }
            } receiveValue: { [weak self] _ in
                for i in 0..<(self?.users.count)! {
                    if self?.users[i].profile?.uid == uid {
                        self?.users.remove(at: i)
                        break
                    }
                }
            }
            .store(in: &self.cancellables)
    }
    
    func unLikeUser(with uid: String) {
        LikesService.shared.unLikeUser(uid: uid)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("SmallUserViewModel: Failed to unlike user")
                    print("SmallUserViewModel-Error: \(error.localizedDescription)")
                    
                case .finished:
                    print("SmallUserViewModel: Unlikes user with id: \(uid)")
                }
            } receiveValue: { [weak self] _ in
                for i in 0..<(self?.users.count)! {
                    if self?.users[i].profile?.uid == uid {
                        self?.users.remove(at: i)
                        break
                    }
                }
            }
            .store(in: &self.cancellables)
    }
}
