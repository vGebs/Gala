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
    
    private var storyMetaService = StoryMetaService.shared

    private var cancellables: [AnyCancellable] = []
    
    @Published var vibesDict: OrderedDictionary<String, [UserPostSimple]> = [:] //[String: [UserPostSimple]]
    
    var imageNames: [String: String] = [
        "We still out here": "squaresClouds",
        "Club's Goin' up": "stayHydrated",
        "Friday night hustle" : "neon-light-frame"
    ]
    
    init() { fetch() }
    
    func fetch() {
        storyMetaService.getStories()
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("StoriesViewModel: Failed to fetch stories")
                    print("StoriesViewModel-err: \(err)")
                case .finished:
                    print("StoriesViewModel: Successfully fetched stories")
                }
            } receiveValue: { [weak self] userPosts in
                //Ok, so before we put the stories in an array, we first need to put all the stories from a vibe into the correct bin
                //The array will have to be an array of arrays
                //Each sub array of the main array will be a vibe
                //Each array will be sorted based on the post dates from the sub Arrays
                //Based on the first post in each sub array, we will order the arrays such that the first array has the most recent posts
                
                //we will have to:
                //  1. loop through the returned array(stories)
                //  2. loop through the posts of each story
                //  3. Place the story into the correct bin
                //      - if the user already exists within a bin, we put their story in the posts array
                
                var final: OrderedDictionary<String, [UserPostSimple]> = [:] //[String: [UserPostSimple]]
                
                //Loop through all returned stories
                for userPost in userPosts {
                    if userPost.posts.count > 1 {
                        
                        //check to see if the story titles are all the same
                        var title: String? = nil
                        var flag = false
                        
                        for post in userPost.posts {
                            if title == nil {
                                title = post.title
                            }
                            
                            if title != post.title {
                                flag = true
                            }
                        }
                        
                        if !flag {
                            if let title = title {
                                if let _ = final[title] {
                                    final[title]! += [userPost]
                                } else {
                                    final[title] = [userPost]
                                }
                            }
                        } else { //if there are some different titles, we need to add them to the right vibe
                            //Begin by looping the returned stories for that user
                            var FlaggedPostIDs: [Date] = []
                            for post in userPost.posts {
                                //for each post we are going to add a new UserPostSimple unless there is already a post from that user in the vibe
                                // so we need to loop through the vibe and make sure that the user has not already posted
                                var flag2 = false
                                if let _ = final[post.title] {
                                    // if the final[post.title] exists, then we need to loop
                                    for userP in final[post.title]! {
                                        if userP.uid == userPost.uid {
                                            //we found out the user has already posted in this vibe
                                            // we now need to loop through the vibes and make sure we dont add the same vibe twice
                                            for vibePost in userP.posts {
                                                if vibePost.pid == post.pid {
                                                    FlaggedPostIDs.append(vibePost.pid)
                                                }
                                            }
                                            flag2 = true
                                        }
                                    }
                                    
                                    if !flag2 {
                                        //if there is no flag that means we can just add the new userPost to the final
                                        let uSimp = UserPostSimple(posts: [post], name: userPost.name, uid: userPost.uid, birthdate: userPost.birthdate, coordinates: userPost.coordinates)
                                        FlaggedPostIDs.append(post.pid)
                                        final[post.title]! += [uSimp]
                                    }
                                } else {
                                    // if the final[post.title] does not exist, we simply add a new UserPostSimple with only the current post we are at
                                    let uSimp = UserPostSimple(posts: [post], name: userPost.name, uid: userPost.uid, birthdate: userPost.birthdate, coordinates: userPost.coordinates)
                                    FlaggedPostIDs.append(post.pid)
                                    final[post.title] = [uSimp]
                                }
                                
                            }
                            //we are now out of the loop, we need to add the stories that are not in the flagged stories
                            for post in userPost.posts {
                                var flag3 = false
                                for id in FlaggedPostIDs {
                                    if id == post.pid {
                                        flag3 = true
                                    }
                                }
                                
                                if !flag3 {
                                    //append story to the users UserPostSimple
                                    if var _ = final[post.title] {
                                        for i in 0..<final[post.title]!.count {
                                            if final[post.title]![i].uid == userPost.uid {
                                                final[post.title]![i].posts.append(Post(pid: post.pid, title: post.title))
                                            }
                                        }
                                    }
                                }
                                // else do nothing, we already have that story
                            }
                        }
                    } else {
                        //If the count of the user posts == 1
                        // we can just add the post to the vibe (assuming that when we refetch, we delete all existing posts).
                        if let _ = final[userPost.posts[0].title] {
                            final[userPost.posts[0].title]! += [userPost]
                        } else {
                            final[userPost.posts[0].title] = [userPost]
                        }
                    }
                }
                
                self?.vibesDict = final
            }
            .store(in: &self.cancellables)
    }
}

struct StoryModel: Identifiable {
    var id = UUID()
    var story: UIImage
    var name: String
    var userID: String
}

class StoryViewModel: ObservableObject {
    var story: StoryModel

    init(_ story: StoryModel){
        self.story = story
    }
}
