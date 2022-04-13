//
//  UserPostSimple.swift
//  Gala
//
//  Created by Vaughn on 2022-03-29.
//

import Foundation
import Combine
import SwiftUI

class UserPostSimple: Identifiable, ObservableObject {
    let id = UUID().uuidString
    @Published var posts: [Post]
    let name: String
    let uid: String
    let birthdate: Date
    let coordinates: Coordinate
    
    @Published var profileImg: UIImage?
    
    @Published var liked = false
    
    private var cancellables: [AnyCancellable] = []
    
    deinit {
        print("UserPostSimple: Deinitializing")
    }
    
    init(posts: [Post], name: String, uid: String, birthdate: Date, coordinates: Coordinate){
        self.posts = posts
        self.name = name
        self.uid = uid
        self.birthdate = birthdate
        self.coordinates = coordinates
        
        for post in posts {
            post.objectWillChange.sink{ [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
        
        ProfileImageService.shared.getProfileImage(uid: uid, index: "0")
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("UserPostSimple: Failed to fetch profileimg w/ id: \(uid)")
                    print("UserPostSimple-err: \(err)")
                case .finished:
                    print("UserPostSimple: Successfully fetched profileimg w/ id: \(uid)")
                }
            } receiveValue: { [weak self] img in
                if let img = img {
                    self?.profileImg = img
                }
            }
            .store(in: &cancellables)
        
        if uid != AuthService.shared.currentUser?.uid {
            observeIfILikedThisUser()
        }
    }
    
    func observeIfILikedThisUser() {
        LikesService.shared.observeIfILikedThisUser(uid: uid) { [weak self] storyLikes, change in
            switch change {
            case .added:
                self?.liked = true
            case .modified:
                self?.liked = true
            case .removed:
                self?.liked = false
            }
        }
    }
}
