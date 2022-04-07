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
    
    deinit {
        print("StoryViewable: Deinitializing")
    }
    
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
                        } receiveValue: { [weak self] uc, img in
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
