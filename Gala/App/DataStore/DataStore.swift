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
        StoryService_CoreData.shared.clear()
        
        SnapService_CoreData.shared.clear()
        
        MatchService_CoreData.shared.clear()
        
        MessageService_CoreData.shared.clear()
        
        UserCoreService_CoreData.shared.clear()
        
        UserAboutService_CoreData.shared.clear()
        
        ProfileImageService_CoreData.shared.clear()
        
        NotificationService.shared.notifications = []
    }
}
