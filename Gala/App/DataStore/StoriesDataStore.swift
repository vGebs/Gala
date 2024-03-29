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
    @Published var myStories: [StoryViewable] = []
    
    @Published var postsILiked: [SimpleStoryLike] = []
    
    private var cancellables: [AnyCancellable] = []
    
    @Published private var matches: [String: MatchedUserCore] = [:]
        
    private init() {
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false) { [weak self] timer in
            DataStore.shared.chats.$matches
                .sink { [weak self] returnedMatches in
                    for newMatch in returnedMatches {
                        if self?.matches[newMatch.uc.userBasic.uid] == nil {
                            self?.matches[newMatch.uc.userBasic.uid] = newMatch
                            self!.getStoriesFromCache(for: newMatch.uc.userBasic.uid)
                            self!.observeStories(for: newMatch.uc.userBasic.uid)
                        }
                    }
                }.store(in: &self!.cancellables)
            
            self?.initializer()
        }
    }
    
    public func initializer() {
        if empty {
            observeMyStories()
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
}

extension StoriesDataStore {
    private func observeMyStories() {
        StoryMetaService.shared.observeMyStories { [weak self] stories in
            self?.myStories = []
            for post in stories {
                let newStory = StoryViewable(pid: post.pid, title: post.title)
                self?.myStories.insert(newStory, at: 0)
            }
        }
    }
    
    private func fetchStories() {
        MatchService_Firebase.shared.getMatches()
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
    }
    
    private func observeStoriesILiked() {
        LikesService.shared.observeStoriesILiked { [weak self] storyLikes in
            
            for like in storyLikes {
                if let change = like.changeType {
                    switch change {
                    case .added:
                        
                        self?.postsILiked.append(like)
                        print("StoriesDataStore: added like")
                    case .modified:
                        
                        if let i = self?.postsILiked.firstIndex(where: { $0.docID == like.docID }) {
                            self?.postsILiked[i] = like
                            print("StoriesDataStore: modified like with id -> \(like.docID)")
                        }
                    case .removed:
                        
                        self?.postsILiked = self!.postsILiked.filter { $0.docID != like.docID }
                        print("StoriesDataStore: removed like with docID -> \(like.docID)")
                    }
                }
            }
        }
    }
}

extension StoriesDataStore {
    private func observeStories(for uid: String) {
        StoryService.shared.observeStories(for: uid) { [weak self] post, change in
            switch change {
            case .added:
                print("added")
                //when we add a new post, we need to:
                //  1. Check and see if we already have posts for that user
                //      a. if there is already a user, we just replace it with the new one
                //      b. if there is not already a user, we add it to the dict
                //  2. we then push all stories to core data
                //  3. Delete any old stories
                if let usimp = post {
                    for i in 0..<usimp.posts.count {
                        
                        if usimp.posts[i].isImage {
                            StoryContentService.shared.getStory(uid: usimp.uid, storyID: usimp.posts[i].pid, title: usimp.posts[i].title)
                                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                                .receive(on: DispatchQueue.main)
                                .sink { completion in
                                    switch completion {
                                    case .failure(let e):
                                        print("StoriesDataStore: Failed to get story img")
                                        print("StoriesDataStore-err: \(e)")
                                    case .finished:
                                        print("StoriesDataStore: Finished getting story img")
                                    }
                                } receiveValue: { img in
                                    if let img = img {
                                        usimp.posts[i].storyImage = img
                                    }
                                    
                                    if i == usimp.posts.count - 1 {
                                        self!.observeStoriesAdditionHelper(for: uid, and: post)
                                    }
                                }.store(in: &self!.cancellables)
                        } else {
                            
                        }
                    }
                }
                
                
            case .modified:
                print("modified")
                //when we update a Story, we need to:
                //  1. replace the existing UserPostSimple
                //  2. Push any new stories CoreData
                ///NOTE: This operation is the same as the .added operation
                
                if let usimp = post {
                    for i in 0..<usimp.posts.count {
                        StoryContentService.shared.getStory(uid: usimp.uid, storyID: usimp.posts[i].pid, title: usimp.posts[i].title)
                            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                            .receive(on: DispatchQueue.main)
                            .sink { completion in
                                switch completion {
                                case .failure(let e):
                                    print("StoriesDataStore: Failed to get story img")
                                    print("StoriesDataStore-err: \(e)")
                                case .finished:
                                    print("StoriesDataStore: Finished getting story img")
                                }
                            } receiveValue: { img in
                                if let img = img {
                                    usimp.posts[i].storyImage = img
                                }
                                
                                if i == usimp.posts.count - 1 {
                                    self!.observeStoriesAdditionHelper(for: uid, and: post)
                                }
                            }.store(in: &self!.cancellables)
                    }
                }
                
            case .removed:
                print("removed")
                //When we remove a story, that means they no longer have any posts
                // So, we need to:
                //  1. Remove the UserPostSimple from the dictionary
                //  2. Delete old posts from core data
                
                //#1
                var toBeDeleted: UserPostSimple?
                for i in 0..<self!.matchedStories.count {
                    if self!.matchedStories[i].uid == uid {
                        toBeDeleted = self!.matchedStories[i]
                        self!.matchedStories.remove(at: i)
                        break
                    }
                }
                
                //#2
                if let toBeDeleted = toBeDeleted {
                    for post in toBeDeleted.posts {
                        StoryService_CoreData.shared.deleteStory(post: post)
                    }
                }
            }
        }
    }
    
    private func observeStoriesAdditionHelper(for uid: String, and post: UserPostSimple?) {
        
        if let post = post {
            
            for i in 0..<post.posts.count {
                StoryService_CoreData.shared.addStory(post: post.posts[i])
                
                if i != post.posts.count - 1 {
                    post.posts[i].storyImage = nil
                }
            }
            
            var isAlreadyAdded = false
            for i in 0..<self.matchedStories.count {
                if self.matchedStories[i].uid == uid {
                    
                    //#1a
                    self.matchedStories[i] = post
                    isAlreadyAdded = true
                }
            }
            
            if !isAlreadyAdded {
                self.matchedStories.append(post)
            }
            
            //StoryService_CoreData.shared.deleteOldStories(for: uid)
        } else {
            //StoryService_CoreData.shared.deleteOldStories(for: uid)
        }
    }
    
    private func getStoriesFromCache(for uid: String) {
        //Need to make stories cache
        var stories = StoryService_CoreData.shared.getAllStories(for: uid)
        
        for i in 0..<stories.count {
            if i == stories.count - 1{
                break
            } else {
                stories[i].storyImage = nil
            }
        }
        
        if stories.count > 0 {
            
            if let userCore = self.matches[uid] {
                let userPostSimple = UserPostSimple(
                    posts: stories,
                    name: userCore.uc.userBasic.name,
                    uid: uid,
                    birthdate: userCore.uc.userBasic.birthdate,
                    coordinates: userCore.uc.searchRadiusComponents.coordinate
                )
                
                self.matchedStories.append(userPostSimple)
            }
        }
    }
}

extension StoriesDataStore {
    private func fetchStories(_ matches: [Match]) -> AnyPublisher<Void, Error> {

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
                            if userPostCopy[i].uid == match.matchedUID {
                                print("Found match in stories")
                                //self?.matchedStories.append(userPostCopy[i])
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
                                                            title: post.title,
                                                            isImage: post.isImage,
                                                            caption: post.caption
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
                    
                    //we need to be able to get all images before placing the values in the dict.
                    
                    for key in final.keys {
                        if let _ = final[key] {
                            for i in 0..<final[key]!.count {
                                for j in 0..<final[key]![i].posts.count {
                                    StoryContentService.shared.getStory(uid: final[key]![i].uid, storyID: final[key]![i].posts[j].pid, title: final[key]![i].posts[j].title)
                                        .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                                        .receive(on: DispatchQueue.main)
                                        .sink { completion in
                                            switch completion {
                                            case .failure(let e):
                                                print("StoriesDataStore: Failed to fetch img")
                                                print("StoriesDataStore-err: \(e)")
                                            case .finished:
                                                print("StoriesDataStore: Finished fetching img")
                                            }
                                        } receiveValue: { img in
                                            if let img = img {
                                                var tempPost = final[key]![i].posts[j]
                                                tempPost.storyImage = img
                                                StoryService_CoreData.shared.addStory(post: tempPost)
                                            }
                                        }.store(in: &self!.cancellables)
                                }
                            }
                        }
                    }
                    
                    self?.vibesDict = final
                    
                    //StoryService_CoreData.shared.deleteOldStories()
                    
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
                    } receiveValue: { [weak self] vibeCoverImage in
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

//What do we need to do?
//We want to put the stories in core data and fetch the asset as needed
//  When we get the stories, we cycle through and add them to core data
//  When we launch the app, stories from core data will be fetched.

//  we will need to store the vibe ID for each story (including match stories)

//  Match stories will be stored in the same format as vibe stories
//      All of the stories will have a boolean identifier: var matched: Bool where true == yes and false == no

//  we need to make a proper fetchMatchStories function instead of just seeing if they come in from the main fetch function
