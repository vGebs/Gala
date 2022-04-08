//
//  StoriesDataStore.swift
//  Gala
//
//  Created by Vaughn on 2022-04-01.
//

import Foundation
import Combine
import FirebaseFirestore
import OrderedCollections

class StoriesDataStore: ObservableObject {
    
    static let shared = StoriesDataStore()
    
    @Published var vibeImages: [VibeCoverImage] = []
    @Published var vibesDict: OrderedDictionary<String, [UserPostSimple]> = [:] //[input->vibe title: [UserPostSimple]]
    
    @Published var matchedStories: [UserPostSimple] = []
    
    @Published var postsILiked: [SimpleStoryLike] = []
    
    private var cancellables: [AnyCancellable] = []
        
    private init() {
        initializer()
    }
    
    public func initializer() {
        if empty {
            fetchStories()
            observeStoriesILiked()
            empty = false
        }
    }
    
    @Published private var empty = true
    
    func clear() {
        vibeImages.removeAll()
        vibesDict.removeAll()
        matchedStories.removeAll()
        postsILiked.removeAll()
        empty = true
    }
    
    func fetchStories() {
        MatchService.shared.getMatches()
            .flatMap { [weak self] matches in
                self!.fetchStories(matches)
            }
            .flatMap { [weak self] _ in
                self!.fetchVibeImages()
            }
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("StoriesViewModel: Failed to fetched stories and matchStories")
                    print("StoriesViewModel-err: \(e)")
                case .finished:
                    print("StoriesViewModel: Successfully fetched stories and matchStories")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
            //.eraseToAnyPublisher()
    }
    
    private func observeStoriesILiked() {
        LikesService.shared.observeStoriesILiked { [weak self] storyLikes, change in
            switch change {
                
            case .added:
                for like in storyLikes {
                    self?.postsILiked.append(like)
                }
                
            case .modified:
                for like in storyLikes {
                    for i in 0..<(self?.postsILiked.count)! {
                        if like.docID == (self?.postsILiked[i].docID)! {
                            self?.postsILiked[i] = like
                        }
                    }
                }
                
            case .removed:
                for story in storyLikes {
                    for i in 0..<(self?.postsILiked.count)! {
                        if story.docID == self?.postsILiked[i].docID {
                            self?.postsILiked.remove(at: i)
                            break
                        }
                    }
                }
            }
        }
    }
}

extension StoriesDataStore {
    private func fetchStories(_ matches: [String]) -> AnyPublisher<Void, Error> {

        return Future<Void, Error> { promise in
            StoryMetaService.shared.getStories()
                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let err):
                        print("StoriesViewModel: Failed to fetch stories")
                        print("StoriesViewModel-err: \(err)")
                        promise(.failure(err))
                    case .finished:
                        print("StoriesViewModel: Successfully fetched stories")
                    }
                } receiveValue: { [weak self] userPosts in
                    
                    var userPostCopy = userPosts
                    
                    var indexes: [Int] = []
                    
                    print("Match Count: \(matches.count)")
                    for match in matches {
                        for i in 0..<userPostCopy.count {
                            if userPostCopy[i].uid == match {
                                print("Found match in stories")
                                self?.matchedStories.append(userPostCopy[i])
                                indexes.append(i)
                                print("added index: \(i)")
                            }
                        }
                    }
                    
                    indexes.sort()
                    
                    for index in indexes.reversed() {
                        userPostCopy.remove(at: index)
                    }
                    
                    //Ok, so before we put the stories in an array, we first need to put all the stories from a vibe into the correct bin
                    //The array will have to be an array of arrays (or dictionary)
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
                    for userPost in userPostCopy {
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
                                                    final[post.title]![i].posts.append(
                                                        Post(
                                                            pid: post.pid,
                                                            uid: final[post.title]![i].uid,
                                                            title: post.title
                                                        )
                                                    )
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
                    promise(.success(()))
                }
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func fetchVibeImages() -> AnyPublisher<Void, Error>{
        self.vibeImages = []
        let count = vibesDict.keys.count
        var counter = 0
        return Future<Void, Error> { [weak self] promise in
            for key in self!.vibesDict.keys {
                VibeImageService.shared.fetchImage(name: key)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let err):
                            print("StoriesViewModel: Failed to fetch vibe image w/ name: \(key)")
                            print("StoriesViewModel-err: \(err)")
                        case .finished:
                            print("StoriesViewModel: Successfully fetched image with name: \(key)")
                        }
                    } receiveValue: {[weak self] vibeCoverImage in
                        if let vibeCoverImage = vibeCoverImage {
                            self?.vibeImages.append(vibeCoverImage)
                            counter += 1
                        }
                        
                        if counter == count {
                            promise(.success(()))
                        }
                    }
                    .store(in: &self!.cancellables)
            }
        }.eraseToAnyPublisher()
    }
}
