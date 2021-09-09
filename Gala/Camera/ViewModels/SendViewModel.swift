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
    
    private var cancellables: [AnyCancellable] = []
    
    init() {}
    
    func postStory() {
        let currentUserID = UserCoreService.shared.currentUserCore!.uid
        let storyMeta = StoryMeta(uid: currentUserID, postID: "123", timeAndDatePosted: "\(Date())")
        storyMetaService
            .postStory(story: storyMeta)
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
}
