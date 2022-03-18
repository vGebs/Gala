//
//  StoryViewModel.swift
//  Gala
//
//  Created by Vaughn on 2022-01-25.
//

import Combine
import SwiftUI

protocol StoryViewModelProtocol {
    func likePost()
    func reportPost()
}

class StoryViewModel: ObservableObject, StoryViewModelProtocol {
    
    private(set) var name: String
    
    private var pid: Date
    private var uid: String

    @Published private(set) var age: String = ""
    @Published private(set) var liked: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    
    init(pid: Date, name: String, birthdate: Date, uid: String) {
        self.name = name
        self.uid = uid
        self.pid = pid
                
        self.age = birthdate.ageString()
        
        self.liked = isStoryLiked()
    }
    
    func likePost() {
        if !isStoryLiked() {
            likePost_()
        }
    }
    
    //LikesContainer not working, so this always falls through
    private func isStoryLiked() -> Bool {
        
        for like in LikesContainer.shared.iLiked {
            if let postID = like.like.storyID {
                if like.like.likedUID == self.uid && postID == pid {
                    self.liked = true
                    return true
                }
            }
        }
        return false
    }
    
    func reportPost() {
        
    }
}

extension StoryViewModel {
    private func likePost_(){
        LikesService.shared.likePost(uid: self.uid, postID: self.pid)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoryViewModel: Failed to like post")
                    print("StoryViewModel-err: \(err)")
                case .finished:
                    print("StoryViewModel: Successfully liked post")
                }
            } receiveValue: { [weak self] _ in
                self?.liked = true
            }
            .store(in: &cancellables)
    }
}
