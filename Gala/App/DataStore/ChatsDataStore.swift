//
//  ChatsDataStore.swift
//  Gala
//
//  Created by Vaughn on 2022-04-01.
//

import Foundation
import Combine
import FirebaseFirestore
import OrderedCollections

class ChatsDataStore: ObservableObject {
    
    static let shared = ChatsDataStore()
    
    private let db = Firestore.firestore()
    
    @Published private(set) var matches: [MatchedUserCore] = []
    @Published private(set) var snaps: OrderedDictionary<String, [Snap]> = [:]
    @Published private(set) var matchMessages: OrderedDictionary<String, [Message]> = [:] //Key = uid, value = [message]
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {
        initializer()
    }
    
    public func initializer() {
        if empty {
            //Fetch all core data before calling firestore listeners
            //we want the most recent date of any transaction. ie, match, snap, message
            //try fetching matches from Core data
            //  if there is data
            //      call observeMatches(fromDate: mostRecentMatchDate)
            //  if there isnt data
            //      call observeMatches(fromDate: year1977)
            observeMatches()
            
            //try fetching snaps from Core data
            //  if there is data
            //      do not call observeSnaps(fromDate: lastMessage/Snap)
            observeSnaps()
            
            //try fetching snaps from Core data
            //  if there is data
            //      do not call observeChats(fromDate: lastMessage/Snap)
            observeChats()
            
            empty = false
        }
    }
    
    @Published private var empty = true
    
    func clear() {
        matches.removeAll()
        snaps.removeAll()
        matchMessages.removeAll()
        empty = true
    }
}


//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Observe Matches ----------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsDataStore {
    private func observeMatches() {
        MatchService.shared.observeMatches() { [weak self] matches in
            for match in matches {
                Publishers.Zip(
                    UserCoreService.shared.getUserCore(uid: match.matchedUID),
                    ProfileImageService.shared.getProfileImage(uid: match.matchedUID, index: "0")
                )
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ChatsDataStore: Failed to fetch uc and img")
                            print("ChatsDataStore-err: \(e)")
                        case .finished:
                            print("ChatsDataStore: Successfully fetched uc and img")
                        }
                    } receiveValue: { [weak self] uc, img in
                        if let uc = uc {
                            if let img = img {
                                
                                if let n = self?.snaps[uc.userBasic.uid] {
                                    if let j = self?.matchMessages[uc.userBasic.uid] {
                                        if n[(self?.snaps[uc.userBasic.uid]?.count)! - 1].snapID_timestamp > j[(self?.matchMessages[uc.userBasic.uid]?.count)! - 1].time {
                                            
                                            let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched, lastMessage: n[(self?.snaps[uc.userBasic.uid]?.count)! - 1].snapID_timestamp)
                                            self?.matches.append(newUCimg)
                                            self?.sortMatches()
                                        } else {
                                            
                                            let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched, lastMessage: j[(self?.matchMessages[uc.userBasic.uid]?.count)! - 1].time)
                                            self?.matches.append(newUCimg)
                                            self?.sortMatches()
                                        }
                                    } else {
                                        let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched, lastMessage: n[(self?.snaps[uc.userBasic.uid]?.count)! - 1].snapID_timestamp)
                                        
                                        self?.matches.append(newUCimg)
                                        self?.sortMatches()
                                    }
                                } else {
                                    if let j = self?.matchMessages[uc.userBasic.uid] {
                                        let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched, lastMessage: j[(self?.matchMessages[uc.userBasic.uid]?.count)! - 1].time)
                                        self?.matches.append(newUCimg)
                                        self?.sortMatches()
                                    } else {
                                        let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched)
                                        self?.matches.append(newUCimg)
                                        self?.sortMatches()
                                    }
                                }
                                
                            } else {
                                
                                if let n = self?.snaps[uc.userBasic.uid] {
                                    let newUCimg = MatchedUserCore(uc: uc, profileImg: UIImage(), timeMatched: match.timeMatched, lastMessage: n[(self?.snaps[uc.userBasic.uid]?.count)! - 1].snapID_timestamp)
                                    
                                    self?.matches.append(newUCimg)
                                    self?.sortMatches()
                                } else {
                                    let newUCimg = MatchedUserCore(uc: uc, profileImg: UIImage(), timeMatched: match.timeMatched)
                                    self?.matches.append(newUCimg)
                                    self?.sortMatches()
                                }
                            }
                        }
                    }.store(in: &self!.cancellables)
            }
        }
    }
}

//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Observe Snaps ------------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsDataStore {
    private func observeSnaps() {
        observeSnapsToMe()
        observeSnapsFromMe()
    }
    
    private func observeSnapsToMe() {
        SnapService.shared.observeSnapsToMe() { [weak self] snaps, docChange in
            if docChange == .added {
                //if the snap is newly added
                // we want to fetch the content and then add it to the array in the correct position
                for snap in snaps {
                    SnapService.shared.fetchSnap(snapID: snap.snapID_timestamp)
                        .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .failure(let e):
                                print("ChatsDataStore: Failed to fetch snap with id: \(snap.snapID_timestamp)")
                                print("ChatsDataStore-err: \(e)")
                            case .finished:
                                print("ChatsDataStore: Successfully fetched snap")
                            }
                        } receiveValue: { [weak self] img in
                            if let i = img {
                                let newSnap = Snap(fromID: snap.fromID, toID: snap.toID, snapID_timestamp: snap.snapID_timestamp, openedDate: snap.openedDate, img: i, docID: snap.docID)
                                
                                self?.setNewLastMessage(uid: snap.fromID, date: snap.snapID_timestamp)

                                if let _ = self?.snaps[snap.fromID] {
                                    let insertIndex = self?.snaps[snap.fromID]!.insertionIndexOf(newSnap, isOrderedBefore: {$0.snapID_timestamp < $1.snapID_timestamp})
                                    
                                    self?.snaps[snap.fromID]?.insert(newSnap, at: insertIndex!)
                                } else {
                                    self?.snaps[snap.fromID] = [newSnap]
                                }
                            } else {
                                let newSnap = Snap(fromID: snap.fromID, toID: snap.toID, snapID_timestamp: snap.snapID_timestamp, openedDate: snap.openedDate, img: nil, docID: snap.docID)

                                self?.setNewLastMessage(uid: snap.fromID, date: snap.snapID_timestamp)

                                if let _ = self?.snaps[snap.fromID] {
                                    let insertIndex = self?.snaps[snap.fromID]!.insertionIndexOf(newSnap, isOrderedBefore: {$0.snapID_timestamp < $1.snapID_timestamp})
                                    
                                    self?.snaps[snap.fromID]?.insert(newSnap, at: insertIndex!)
                                } else {
                                    self?.snaps[snap.fromID] = [newSnap]
                                }
                            }
                        }
                        .store(in: &self!.cancellables)
                }
            } else if docChange == .modified {
                //cycle through the snaps received and the snaps we have,
                // if there is a match, replace the snap with the new one
                for snap in snaps {
                    if let _ = self?.snaps[snap.fromID] {
                        for i in 0..<(self?.snaps[snap.fromID]!.count)! {
                            if self?.snaps[snap.fromID]![i].snapID_timestamp == snap.snapID_timestamp {
                                self?.snaps[snap.fromID]![i] = snap
                                print("ChatsDataStore: modified snap with id -> \(snap.docID)")
                            }
                        }
                    }
                }
            } else if docChange == .removed {
                //cycle through the snaps received and the snaps we have,
                // if there is a match, remove that snap
                for snap in snaps {
                    if let _ = self?.snaps[snap.fromID] {
                        for i in 0..<(self?.snaps[snap.fromID]!.count)! {
                            if self?.snaps[snap.fromID]![i].snapID_timestamp == snap.snapID_timestamp {
                                self?.snaps[snap.fromID]!.remove(at: i)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func observeSnapsFromMe() {
        SnapService.shared.observerSnapsfromMe { [weak self] snaps, docChange in
            if docChange == .added {
                // if the snap is newly added,
                // add it in the correct position (we do not need to pull the image because it is from us.
                for snap in snaps {
                    self?.setNewLastMessage(uid: snap.toID, date: snap.snapID_timestamp)

                    if let _ = self?.snaps[snap.toID] {
                        let insertIndex = self?.snaps[snap.toID]!.insertionIndexOf(snap, isOrderedBefore: {$0.snapID_timestamp < $1.snapID_timestamp})
                        
                        self?.snaps[snap.toID]?.insert(snap, at: insertIndex!)
                    } else {
                        self?.snaps[snap.toID] = [snap]
                    }
                }
            } else if docChange == .modified {
                //cycle through the snaps received and the snaps we have,
                // if there is a match, replace the snap with the new one
                for snap in snaps {
                    if let _ = self?.snaps[snap.toID] {
                        for i in 0..<(self?.snaps[snap.toID]!.count)! {
                            if self?.snaps[snap.toID]![i].snapID_timestamp == snap.snapID_timestamp {
                                self?.snaps[snap.toID]![i] = snap
                                print("ChatsDataStore: modified snap with id -> \(snap.docID)")
                            }
                        }
                    }
                }
            } else if docChange == .removed {
                //cycle through the snaps received and the snaps we have,
                // if there is a match, remove that snap
                for snap in snaps {
                    if let _ = self?.snaps[snap.toID] {
                        for i in 0..<(self?.snaps[snap.toID]!.count)! {
                            if self?.snaps[snap.toID]![i].snapID_timestamp == snap.snapID_timestamp {
                                self?.snaps[snap.toID]!.remove(at: i)
                                print("ChatsDataStore: removed snap with id -> \(snap.docID)")
                                return
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Observe Messages ---------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsDataStore {
    private func observeChats() {
        
        var timestamp: Timestamp
        
        if let date = MessageService_CoreData.shared.getMostRecentMessageDate() {
            timestamp = Timestamp(date: date)
            getMostRecentMessagesCD()
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            timestamp = Timestamp(date: formatter.date(from: "1997/06/12 07:30")!)
        }
        
        observeChatsFromMe(fromDate: timestamp)
        observeChatsToMe(fromDate: timestamp)
    }
    
    private func observeChatsFromMe(fromDate: Timestamp) {
        MessageService_Firebase.shared.observeChatsFromMe(from: fromDate) { [weak self] messages, change in
            switch change {
            case .added:
                //we want to only store the most recent message for the receipt
                // everything else is stored in core data
                
                for message in messages {
                    
                    MessageService_CoreData.shared.addMessage(msg: message)
                    
                    self?.setNewLastMessage(uid: message.toID, date: message.time)
                    self?.checkForAnyOpenedSnapsAndDelete(message.toID)
                    
                    if let _ = self?.matchMessages[message.toID] {
                        let insertIndex = self?.matchMessages[message.toID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
                        self?.matchMessages[message.toID]?.insert(message, at: insertIndex!)
                        
                        //After each insertion we will then delete all other values in the array, only leaving the most recent
                        if let last = self?.matchMessages[message.fromID]?.last {
                            self?.matchMessages[message.fromID] = [last]
                        }
                        
                        print("ChatsDataStore: Fetched message from me (appended): \(message.message)")
                        
                    } else {
                        self?.matchMessages[message.toID] = [message]
                        print("ChatsDataStore: Fetched message from me (created): \(message.message)")
                    }
                }
            case .modified:
                for message in messages {
                    
                    MessageService_CoreData.shared.updateMessage(message: message)
                    
                    if let _ = self?.matchMessages[message.toID] {
                        for i in 0..<(self?.matchMessages[message.toID]!.count)! {
                            if self?.matchMessages[message.toID]![i].docID == message.docID {
                                self?.matchMessages[message.toID]![i] = message
                            }
                        }
                    }
                }
            case .removed:
                print("")
            }
        }
    }
    
    private func observeChatsToMe(fromDate: Timestamp) {
        MessageService_Firebase.shared.observeChatsToMe(from: fromDate) { [weak self] messages, change in
            switch change {
            case .added:
                for message in messages {
                    self?.setNewLastMessage(uid: message.fromID, date: message.time)
                    
                    MessageService_CoreData.shared.addMessage(msg: message)
                    
                    if let _ = self?.matchMessages[message.fromID] {
                        let insertIndex = self?.matchMessages[message.fromID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
                        
                        self?.matchMessages[message.fromID]?.insert(message, at: insertIndex!)
                        
                        //After each insertion we will then delete all other values in the array, only leaving the most recent
                        if let last = self?.matchMessages[message.fromID]?.last {
                            self?.matchMessages[message.fromID] = [last]
                        }
                        
                        print("ChatsDataStore: Fetched message to me (appended): \(message.message)")
                    } else {
                        self?.matchMessages[message.fromID] = [message]
                        print("ChatsDataStore: Fetched message to me (created): \(message.message)")
                    }
                }
            case .modified:
                for message in messages {
                    if let _ = self?.matchMessages[message.fromID] {
                        
                        MessageService_CoreData.shared.updateMessage(message: message)
                        
                        for i in 0..<(self?.matchMessages[message.fromID]!.count)! {
                            if self?.matchMessages[message.fromID]![i].docID == message.docID {
                                self?.matchMessages[message.fromID]![i] = message
                                print("ChatsDataStore: Modified message")
                            }
                        }
                    }
                }
            case .removed:
                print("")
            }
        }
    }
    
    private func getMostRecentMessagesCD() {
        //we want to fetch all messages and place only the newest element in the array
        if let messages = MessageService_CoreData.shared.getAllMessages() {
            for message in messages {
                if message.fromID == AuthService.shared.currentUser!.uid {
                    if let _ = self.matchMessages[message.toID] {
                        if self.matchMessages[message.toID]![self.matchMessages[message.toID]!.count - 1].time < message.time {
                            self.matchMessages[message.toID]?.removeAll()
                            self.matchMessages[message.toID]?.append(message)
                        }
                    } else {
                        self.matchMessages[message.toID] = [message]
                    }
                } else if message.toID == AuthService.shared.currentUser!.uid {
                    if let _ = self.matchMessages[message.fromID] {
                        if self.matchMessages[message.fromID]![self.matchMessages[message.fromID]!.count - 1].time < message.time {
                            self.matchMessages[message.fromID]?.removeAll()
                            self.matchMessages[message.fromID]?.append(message)
                        }
                    } else {
                        self.matchMessages[message.fromID] = [message]
                    }
                }
            }
        }
    }
}

//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Helpers ------------------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsDataStore {
    private func setNewLastMessage(uid: String, date: Date) {
        for i in 0..<self.matches.count {
            if matches[i].uc.userBasic.uid == uid {
                if matches[i].lastMessage == nil {
                    matches[i].lastMessage = date
                    sortMatches()
                } else if matches[i].lastMessage! < date {
                    matches[i].lastMessage = date
                    sortMatches()
                }
            }
        }
    }
    
    private func sortMatches() {
        matches.sort { (i1, i2) -> Bool in
            let t1 = i1.lastMessage ?? i1.timeMatched
            let t2 = i2.lastMessage ?? i2.timeMatched
            return t1 < t2
        }
        
        matches = matches.reversed()
    }
    
    private func checkForAnyOpenedSnapsAndDelete(_ toUID: String) {
        //Check to see if there are any openedSnaps, if there are, delete them all
        if let snaps = snaps[toUID] {
            if snaps.count > 1 {
                for i in 0..<snaps.count - 1 {
                    if snaps[i].openedDate != nil {
                        SnapService.shared.deleteMeta(snap: snaps[i])
                            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                            .receive(on: DispatchQueue.main)
                            .sink { completion in
                                switch completion {
                                case .failure(let e):
                                    print("ChatViewModel: Failed to delete snap")
                                    print("ChatViewModel-err: \(e)")
                                case .finished:
                                    print("ChatViewModel: Finished deleting snap")
                                }
                            } receiveValue: { _ in }
                            .store(in: &cancellables)
                    }
                }
            }
        }
    }
}

