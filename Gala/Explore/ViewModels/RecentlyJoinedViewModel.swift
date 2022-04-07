//
//  RecentlyJoinedViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-04.
//

import Foundation
import Combine
import SwiftUI

class RecentlyJoinedViewModel: ObservableObject, SmallUserViewModelProtocol {
    
    private var recents = RecentlyJoinedUserService.shared
    private var likeService = LikesService.shared
    
    @Published private(set) var users: [SmallUserViewModel] = []
    
    private var cancellables: [AnyCancellable] = []
    
    deinit {
        print("RecentlyJoinedViewModel: Deinitializing")
    }
    
    init() {
        DataStore.shared.recents.$users
            .sink { [weak self] users in
                self?.users = users
            }.store(in: &cancellables)
    }
    
    func likeUser(with uid: String) {
        LikesService.shared.likeRecentlyJoinedUser(uid: uid)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("SmallUserViewModel: Failed to like user")
                    print("SmallUserViewModel-Error: \(error.localizedDescription)")
                case .finished:
                    print("SmallUserViewModel: Liked recently joined user with id: \(uid)")
                }
            } receiveValue: { [weak self] _ in
                for i in 0..<(self?.users.count)! {
                    if self?.users[i].profile?.userBasic.uid == uid {
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
                    if self?.users[i].profile?.userBasic.uid == uid {
                        self?.users.remove(at: i)
                        break
                    }
                }
            }
            .store(in: &self.cancellables)
    }
}
