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
    @Published var demoStories: [UserPostSimple] = []
    
    @Published var postsILiked: [SimpleStoryLike] = []
    
    @Published var currentVibe: [UserPostSimple] = [] //Will contain all stories from a particular vibe
    @Published var currentStory = "" //Will contain the current vibeID
    @Published var showVibeStory = false
    @Published var showMatchStory = false
    @Published var showDemoStory = false
    
    private var cancellables: [AnyCancellable] = []

    deinit {
        print("StoriesViewModel: Deinitializing")
    }
    
    init() {
        DataStore.shared.stories.$vibeImages
            .sink { [weak self] vibeImgs in
                withAnimation {
                    self?.vibeImages = vibeImgs
                }
            }.store(in: &cancellables)
        
        DataStore.shared.stories.$vibesDict
            .sink { [weak self] vibes in
                withAnimation {
                    self?.vibesDict = vibes
                }
            }.store(in: &cancellables)
        
        DataStore.shared.stories.$matchedStories
            .sink { [weak self] matchStories in
                withAnimation {
                    self?.matchedStories = matchStories
                }
            }.store(in: &cancellables)
        
        DataStore.shared.stories.$postsILiked
            .sink { [weak self] likes in
                withAnimation {
                    self?.postsILiked = likes
                }
            }.store(in: &cancellables)
    }
    
    func showDemo() {
        for i in 0..<10 {
            let newDemo = UserPostSimple(
                posts: [
                    Post(pid: Date().adding(minutes: -10), uid: "\(i)", title: "Demo", storyImage: UIImage(named: "Gala")),
                    Post(pid: Date().adding(minutes: -5), uid: "\(i)", title: "Demo", storyImage: UIImage(named: "Gala")),
                    Post(pid: Date(), uid: "\(i)", title: "Demo", storyImage: UIImage(named: "Gala"))
                ],
                name: "Demo",
                uid: "\(i)",
                birthdate: Date("1997-06-12"),
                coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
                profileImg: UIImage(systemName: "person.crop.circle")!
            )
            
            self.demoStories.append(newDemo)
        }
    }
    
    func getMatchStoryImage(uid: String, pid: Date) {
        if let story = StoryService_CoreData.shared.getStory(with: uid, and: pid) {
            for i in 0..<matchedStories.count {
                if matchedStories[i].uid == uid {
                    for j in 0..<matchedStories[i].posts.count {
                        if matchedStories[i].posts[j].pid == pid {
                            matchedStories[i].posts[j] = story
                        }
                    }
                }
            }
        }
    }
    
    func getDemoImage() {
        
    }
    
    func getVibeStoryImage(uid: String, pid: Date, vibeTitle: String) {
        if let story = StoryService_CoreData.shared.getStory(with: uid, and: pid) {
            if let users = vibesDict[vibeTitle] {
                for i in 0..<users.count {
                    if uid == users[i].uid {
                        for j in 0..<users[i].posts.count {
                            if pid == users[i].posts[j].pid {
                                users[i].posts[j] = story
                            }
                        }
                    }
                }
            }
        }
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
            if story.likedUID == uid {
                docID = story.docID
                break
            }
        }
                
        if docID != "" {
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
}

//var demoStoriesArr: [UserPostSimple] = [
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "0", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "0", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "0", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "0",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "1", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "1", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "1", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "1",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "2", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "2", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "2", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "2",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "3", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "3", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "3", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "3",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "4", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "4", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "4", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "4",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "5", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "5", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "5", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "5",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "6", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "6", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "6", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "6",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "7", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "7", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "7", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "7",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "8", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "8", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "8", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "8",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    ),
//    UserPostSimple(
//        posts: [
//            Post(pid: Date(), uid: "9", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -5), uid: "9", title: "Demo", storyImage: UIImage(named: "Gala")),
//            Post(pid: Date().adding(minutes: -10), uid: "9", title: "Demo", storyImage: UIImage(named: "Gala"))
//        ],
//        name: "Demo",
//        uid: "9",
//        birthdate: Date("1997-06-12"),
//        coordinates: Coordinate(lat: 50.445210, lng: -104.618896),
//        profileImg: UIImage(systemName: "person.crop.circle")!
//    )
//]
