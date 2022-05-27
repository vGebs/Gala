//
//  DataStore.swift
//  Gala
//
//  Created by Vaughn on 2022-03-31.
//

//Link for Reducing app launch time: https://developer.apple.com/documentation/xcode/reducing-your-app-s-launch-time

import Foundation
import Combine

class DataStore: ObservableObject {
    
    static let shared = DataStore()
    
    @Published var chats: ChatsDataStore
    @Published var recents: RecentlyJoinedDataStore
    @Published var stories: StoriesDataStore
    
    private init() {
        chats = ChatsDataStore.shared
        recents = RecentlyJoinedDataStore.shared
        stories = StoriesDataStore.shared
    }
    
    public func initialize() {
        chats.initializer()
        recents.initialier()
        stories.initializer()
    }
    
    func clear() {
        chats.clear()
        recents.clear()
        stories.clear()
    }
    
    func clearCache() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            StoryService_CoreData.shared.clear() //
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            SnapService_CoreData.shared.clear()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            MatchService_CoreData.shared.clear() //
        }

        DispatchQueue.global(qos: .userInitiated).async {
            MessageService_CoreData.shared.clear() //
        }

        DispatchQueue.global(qos: .userInitiated).async {
            UserCoreService_CoreData.shared.clear() //
        }

        DispatchQueue.global(qos: .userInitiated).async {
            UserAboutService_CoreData.shared.clear() //
        }

        DispatchQueue.global(qos: .userInitiated).async {
            ProfileImageService_CoreData.shared.clear() //
        }
    }
}
