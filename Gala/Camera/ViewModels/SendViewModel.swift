//
//  SendViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-09.
//

import Combine
import SwiftUI

class SendViewModel: ObservableObject {
    
    private var storyMetaService: StoryMetaService = StoryMetaService.shared
    private var currentUserCore: UserCore = UserCoreService.shared.currentUserCore!
    private var cancellables: [AnyCancellable] = []
    
    init() {}
    
    func postStory() {
        let storyMeta = StoryMeta(
            postID: "123",
            timeAndDatePosted: "\(Date())",
            userCore: currentUserCore
        )
        
        storyMetaService.postStory(story: storyMeta)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("SendViewModel: Failed to post story")
                    print("SendViewModel-Error: \(err.localizedDescription)")
                case .finished:
                    print("SendViewModel: Successfully posted story with ID: \(storyMeta.postID)")
                }
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
    }
    
    func getMyStories() {
        storyMetaService.getMyStories()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("SendViewModel: Failed to get recents")
                    print("SendViewModel-Error: \(err.localizedDescription)")
                case .finished:
                    print("SendViewModel: Successfully got recents")
                }
            } receiveValue: { storyMeta in
                
            }.store(in: &self.cancellables)
    }
}
