//
//  RecentlyJoinedDataStore.swift
//  Gala
//
//  Created by Vaughn on 2022-04-01.
//

import Foundation
import Combine
import FirebaseFirestore
import OrderedCollections

class RecentlyJoinedDataStore: ObservableObject {
    
    static let shared = RecentlyJoinedDataStore()
    
    @Published private(set) var users: [SmallUserViewModel] = []
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] timer in
            self?.initialier()
        }
    }
    
    public func initialier() {
        if empty {
            getUsers()
            empty = false
        }
    }
    
    @Published private var empty = true
    
    func clear() {
        users.removeAll()
        empty = true
    }
    
    private func getUsers() {
        Publishers.Zip(
            RecentlyJoinedUserService.shared.getRecents(),
            LikesService.shared.getPeopleILiked()
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
                                if user.element.userBasic.uid == iLiked[i].like.likedUID {
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
                print("ExploreViewModel-recents: nil")
            }
        }
        .store(in: &self.cancellables)
    }
}
