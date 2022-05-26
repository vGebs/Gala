//
//  StoryService_CoreData.swift
//  Gala
//
//  Created by Vaughn on 2022-05-20.
//

import CoreData
import Combine
import SwiftUI

class StoryService_CoreData {
    static let shared = StoryService_CoreData()
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "StoryCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("StoryService_CoreData: Failed to load container")
                print("StoryService_CoreData-err: \(e)")
            }
        }
    }
    
    //we are storing the posts in this format:
    //->Post
    //      uid
    //      pid
    //      title
    //      asset
    
    func addStory(post: Post) {
        if let _ = getStoryCD(with: post.uid, and: post.pid) {
            print("StoryService_CoreData: Tried to re add story")
        } else {
            
            let postCD = StoryCD(context: persistentContainer.viewContext)
            if bundleStoryCD(post: post, cd: postCD) {
                do {
                    try persistentContainer.viewContext.save()
                    
                    print("StoryService_CoreData: Finished saving story with uid -> \(post.uid) && pid -> \(post.pid)")
                } catch {
                    print("StoryService_CoreData: Failed to add new story: \(error)")
                }
            } else {
                print("StoryService_CoreData: Cannot store story if img is nil")
            }
        }
    }
    
    func getStory(with uid: String, and pid: Date) -> Post? {
        if let story = getStoryCD(with: uid, and: pid) {
            return bundleStory(cd: story)
        } else {
            print("StoryService_CoreData: No story with uid -> \(uid) && pid -> \(pid)")
            return nil
        }
    }
    
    func deleteStory(post: Post) {
        if let storyCD = getStoryCD(with: post.uid, and: post.pid) {
            persistentContainer.viewContext.delete(storyCD)

            do {
                try persistentContainer.viewContext.save()
                print("StoryService_CoreData: Successfully deleted story w/ uid -> \(post.pid) && pid -> \(post.pid)")
                return
            } catch {
                print("StoryService_CoreData: Failed to delete story")
                print("StoryService_CoreData: Failed to save context")
                return
            }
        } else {
            print("StoryService_CoreData: no story to delete")
        }
    }
    
    func getAllStories(for uid: String) -> [Post] {
        let fetchRequest: NSFetchRequest<StoryCD> = StoryCD.fetchRequest()
        let uidPredicate = NSPredicate(format: "uid == %@", uid)

        let pidSortDescriptor = NSSortDescriptor(key: "pid", ascending: true)
        fetchRequest.sortDescriptors = [pidSortDescriptor]
        
        fetchRequest.predicate = uidPredicate
        
        do {
            let storiesCD = try persistentContainer.viewContext.fetch(fetchRequest)
            
            var stories: [Post] = []
            
            for story in storiesCD {
                stories.append(bundleStory(cd: story))
            }
            
            return stories
        } catch {
            
            print("StoryService_CoreData: Failed to fetch stories for user with uid: \(uid)")
            print("StoryService_CoreData: Failed to save context")
            
            return []
        }
    }
    
    func deleteOldStories(for uid: String) {
        let posts = getAllStories(for: uid)
        var toBeDeleted: [Post] = []
        
        for post in posts {
            let diffComponents = Calendar.current.dateComponents([.hour], from: post.pid, to: Date())
            let hours = diffComponents.hour
            if let hours = hours {
                if hours >= 24 {
                    toBeDeleted.append(post)
                }
            }
        }
        
        for post in toBeDeleted {
            self.deleteStory(post: post)
        }
    }
}

extension StoryService_CoreData {

    private func getStoryCD(with uid: String, and pid: Date) -> StoryCD? {
        let fetchRequest: NSFetchRequest<StoryCD> = StoryCD.fetchRequest()
        
        let uidPredicate = NSPredicate(format: "uid == %@", uid)
        let pidPredicate = NSPredicate(format: "pid == %@", pid as CVarArg)
        let logicalANDPredicate = NSCompoundPredicate(type: .and, subpredicates: [uidPredicate, pidPredicate])

        fetchRequest.predicate = logicalANDPredicate
        
        do {
            let story = try persistentContainer.viewContext.fetch(fetchRequest)
            if story.count > 0 {
                return story[0]
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

extension StoryService_CoreData {
    
    private func bundleStory(cd: StoryCD) -> Post {
        return Post(
            pid: cd.pid!,
            uid: cd.uid!,
            title: cd.title!,
            storyImage: UIImage(data: cd.asset!)!
        )
        
        
    }
    
    private func bundleStoryCD(post: Post, cd: StoryCD) -> Bool {
        if let img = post.storyImage {
            cd.uid = post.uid
            cd.pid = post.pid
            cd.title = post.title
            
            if let data = img.jpegData(compressionQuality: compressionQuality) {
                cd.asset = data
                return true
            }
            
            return false
            
        } else {
           return false
        }
    }
}

