//
//  DataStore.swift
//  Gala
//
//  Created by Vaughn on 2022-03-31.
//

import Foundation
import Combine
import FirebaseFirestore
import OrderedCollections

class DataStore: ObservableObject {
    
    static let shared = DataStore()
    
    @Published var chatsData: ChatsDataStore
    @Published var recents: RecentlyJoinedDataStore
    @Published var stories: StoriesDataStore
    
    private init() {
        chatsData = ChatsDataStore.shared
        recents = RecentlyJoinedDataStore.shared
        stories = StoriesDataStore.shared
    }
    
    func clear() {
        chatsData.clear()
        recents.clear()
        stories.clear()
    }
}
