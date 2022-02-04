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
    
    private var cancellables: [AnyCancellable] = []
    
    init(pid: Date, name: String, birthdate: Date, uid: String) {
        self.name = name
        self.uid = uid
        self.pid = pid
                
        self.age = birthdate.ageString()
    }
    
    func likePost() {
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
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func reportPost() {
        
    }
}
