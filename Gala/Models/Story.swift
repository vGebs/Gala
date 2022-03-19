//
//  StoryModel.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import SwiftUI
import Combine
import FirebaseFirestore

//Some changes:
//  - We are going to make 'postID_timeAndDatePosted' an array
//Therefore we need to:
//  1. Change the myStories array in StoryService to just one
//      StoryMeta object (which is an optional)
//  2. When we make a new post, we add the date to the array (which
//      is the storyID).
//  3. We will also have to change the return for 'getMyStories' from -> [StoryMeta],
//      to -> StoryMeta
//      
//  We also likely will not need the 'Story' Model becuase we are pulling the images
//      once we get the meta and pass it to the object. Wait and see what is needed.

struct StoryWithVibe: Identifiable {
    var id = UUID()
    var pid: Date
    var title: String
}

class StoryViewable: ObservableObject, Identifiable {
    var id = UUID().uuidString
    
    var pid: Date
    var title: String
    
    var storyImg: UIImage? {
        willSet {
            objectWillChange.send()
        }
    }
    
    var likes: [LikeWithProfile] {
        willSet{
            objectWillChange.send()
        }
    }
    
    private var cancellables: [AnyCancellable] = []
    
    init(pid: Date, title: String) {
        self.title = title
        self.likes = []
        self.pid = pid
        
        StoryContentService.shared.getStory(uid: AuthService.shared.currentUser!.uid, storyID: pid)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion{
                case .failure(let e):
                    print("StoryViewable: Failed to fetch story")
                    print("StoryViewable-err: \(e)")
                case .finished:
                    print("StoryViewable: Successfully fetched story")
                }
            } receiveValue: { [weak self] img in
                if let img = img {
                    self?.storyImg = img
                }
            }.store(in: &cancellables)

        
        LikesService.shared.observeLikesForPost(pid: pid) { [weak self] likes, change in
            switch change {
            case .added:
                for like in likes {
                    ProfileService.shared.getProfile(uid: like.likerUID)
                        .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .failure(let e):
                                print("StoryViewable: failed to fetch userCore and img")
                                print("StoryViewable-err: \(e)")
                            case .finished:
                                print("StoryViewable: Successfully fetched userCore and img")
                            }
                        } receiveValue: { uc, img in
                            if let uc = uc, let img = img {
                                let newLike = LikeWithProfile(like: like, userCore: uc, profileImg: img)
                                self?.likes.append(newLike)
                            } else if let uc = uc {
                                let newLike = LikeWithProfile(like: like, userCore: uc, profileImg: nil)
                                self?.likes.append(newLike)
                            }
                        }.store(in: &self!.cancellables)
                }
            case .modified:
                print("")
            case .removed:
                for like in likes {
                    for i in 0..<(self?.likes.count)! {
                        if like.likerUID == self?.likes[i].like.likerUID {
                            self?.likes.remove(at: i)
                            break
                        }
                    }
                }
            }
        }
    }
}

class Post: Identifiable, ObservableObject {
    let id = UUID()
    let pid: Date
    let uid: String
    let title: String
    
    var storyImage: UIImage? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published private(set) var timeSincePost: String = ""

    private var cancellables: [AnyCancellable] = []
    
    init(pid: Date, uid: String, title: String) {
        self.pid = pid
        self.title = title
        self.uid = uid
        
        StoryContentService.shared.getStory(uid: uid, storyID: pid)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("Post Model: Failed to fetch story with pid: \(pid)")
                    print("Post Model-err: \(err)")
                case .finished:
                    print("Post Model: Successfully fetched story with pid: \(pid)")
                }
            } receiveValue: { [weak self] img in
                if let img = img {
                    self?.storyImage = img
                }
            }.store(in: &cancellables)

        self.timeSincePost = secondsToHoursMinutesSeconds(Int(pid.timeIntervalSinceNow))
        
    }
    
    // extract this method and add it to date.
    // will need to input a date and then from there get seconds and then we can get the output
    private func secondsToHoursMinutesSeconds(_ seconds: Int) -> String { //(Int, Int, Int)
        
        if abs(((seconds % 3600) / 60)) == 0 {
            let secondString = "\(abs((seconds % 3600) / 60))s"
            return secondString
        } else if abs((seconds / 3600)) == 0 {
            let minuteString = "\(abs((seconds % 3600) / 60))m"
            return minuteString
        } else {
            let hourString = "\(abs(seconds / 3600))h"
            return hourString
        }
    }
}

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
        
        ProfileImageService.shared.getProfileImage(id: uid, index: "0")
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
