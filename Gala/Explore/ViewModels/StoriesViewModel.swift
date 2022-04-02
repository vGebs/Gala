//
//  StoriesViewModel.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import Combine
import SwiftUI
import OrderedCollections

class StoriesViewModel: ObservableObject {
        
    @Published var vibeImages: [VibeCoverImage] = []
    @Published var vibesDict: OrderedDictionary<String, [UserPostSimple]> = [:] //[input->vibe title: [UserPostSimple]]
    
    @Published var matchedStories: [UserPostSimple] = []
    
    @Published var postsILiked: [SimpleStoryLike] = []
    
    @Published var currentVibe: [UserPostSimple] = [] //Will contain all stories from a particular vibe
    @Published var currentStory = "" //Will contain the current vibeID
    @Published var showVibeStory = false
    @Published var showMatchStory = false
    
    private var cancellables: [AnyCancellable] = []

    deinit {
        print("StoriesViewModel: Deinitializing")
    }
    
    init() {
        DataStore.shared.stories.$vibeImages
            .sink { [weak self] vibeImgs in
                self?.vibeImages = vibeImgs
            }.store(in: &cancellables)
        
        DataStore.shared.stories.$vibesDict
            .sink { [weak self] vibes in
                self?.vibesDict = vibes
            }.store(in: &cancellables)
        
        DataStore.shared.stories.$matchedStories
            .sink { [weak self] matchStories in
                self?.matchedStories = matchStories
            }.store(in: &cancellables)
        
        DataStore.shared.stories.$postsILiked
            .sink { [weak self] likes in
                self?.postsILiked = likes
            }.store(in: &cancellables)
    }
    
    func fetch() {
        DataStore.shared.stories.fetchStories()
    }
    
    func postIsLiked(uid: String, pid: Date) -> Bool {
        for story in postsILiked {
            if story.likedUID == uid && story.pid == pid {
                return true
            }
        }
        return false
    }
    
    func likePost(uid: String, pid: Date) {
        LikesService.shared.likePost(uid: uid, postID: pid)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("StoryCardViewModel: Failed to like post")
                    print("StoryCardViewModel-err: \(e)")
                case .finished:
                    print("StoryCardViewModel: Successfully liked post")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func unLikePost(uid: String, pid: Date) {
        var docID = ""
        for story in postsILiked {
            if story.pid == pid && story.likedUID == uid {
                docID = story.docID
                print("DocID: \(docID)")
                break
            }
        }
        print("DocID: \(docID)")
        LikesService.shared.unLikePost(docID: docID)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("StoriesViewModel: Failed to unlike post")
                    print("StoriesViewModel-err: \(e)")
                case .finished:
                    print("StoriesViewModel: Successfully unliked user")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
