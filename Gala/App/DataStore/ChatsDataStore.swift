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
    @Published private(set) var messages: OrderedDictionary<String, [Message]> = [:] //Key = uid, value = [message]
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] timer in
            self?.initializer()
        }
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
        messages.removeAll()
        empty = true
    }
    
    func unMatchUser(with uid: String) {
        var docID: String = ""
        
        for match in matches {
            if match.uc.userBasic.uid == uid {
                docID = match.matchDocID
            }
        }
        
        MatchService_Firebase.shared.unMatchUser(with: docID)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ProfileViewModel: Failed to unMatch user with uid: \(uid)")
                    print("ProfileViewModel-err: \(e)")
                case .finished:
                    print("ProfileViewModel: Finished unMatching from user w/ uid -> \(uid)")
                }
            } receiveValue: { _ in
                
                let matchedStories = DataStore.shared.stories.matchedStories
                
                for i in 0..<matchedStories.count {
                    if matchedStories[i].uid == uid {
                        DataStore.shared.stories.matchedStories.remove(at: i)
                        return
                    }
                }
            }
            .store(in: &cancellables)
    }
}


//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Observe Matches ----------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsDataStore {
    
    public func isMatch(uid: String) -> Bool {
        return matches.contains { $0.uc.userBasic.uid == uid }
        
//        for match in matches {
//            if match.uc.userBasic.uid == uid {
//                return true
//            }
//        }
//        return false
    }
    
    private func observeMatches() {
        
        if let matches = getMatchesFromCD() {
            for match in matches {
                getMatchProfile(match)
                observeMatchUserCore(for: match)
                observeProfileImage(for: match)
            }
        }
        
        MatchService_Firebase.shared.observeMatches() { [weak self] matches, change in
            switch change {
            case .added:
                for match in matches {
                    self!.getMatchProfile(match)
                    //for each match, we want to observe their UserCore
                    self!.observeMatchUserCore(for: match)
                    self!.observeProfileImage(for: match)
                }
                
            case .removed:
                for i in 0..<self!.matches.count {
                    for m in matches {
                        if self!.matches[i].uc.userBasic.uid == m.matchedUID {
                            
                            //Call these functions async
                            DispatchQueue.global(qos: .userInitiated).async {
                                MatchService_CoreData.shared.deleteMatch(for: m.matchedUID)      //DONE
                            }
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                MessageService_CoreData.shared.deleteMessages(from: m.matchedUID)//DONE
                            }
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                ProfileService.shared.deleteProfile(for: m.matchedUID)           //DONE
                            }
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                SnapService_CoreData.shared.deleteSnaps(from: m.matchedUID)      //
                            }
                            
                            print("ChatsDataStore: removing user with uid -> \(m.matchedUID)")
                            self!.matches.remove(at: i)
                            return
                        }
                    }
                }
            case .modified:
                print("")
            }
        }
    }
    
    private func getMatchProfile(_ match: Match) {
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
                            if let j = self?.messages[uc.userBasic.uid] {
                                if n[(self?.snaps[uc.userBasic.uid]?.count)! - 1].snapID_timestamp > j[(self?.messages[uc.userBasic.uid]?.count)! - 1].time {
                                    
                                    let newUCimg = MatchedUserCore(
                                        uc: uc,
                                        profileImg: img,
                                        timeMatched: match.timeMatched,
                                        lastMessage: n[(self?.snaps[uc.userBasic.uid]?.count)! - 1].snapID_timestamp,
                                        matchDocID: match.docID
                                    )
                                    
                                    self?.matches.append(newUCimg)
                                    self?.sortMatches()
                                    
                                    self?.addMatchUserCoreAndProfileImg(uc, img)
                                } else {
                                    
                                    let newUCimg = MatchedUserCore(
                                        uc: uc,
                                        profileImg: img,
                                        timeMatched: match.timeMatched,
                                        lastMessage: j[(self?.messages[uc.userBasic.uid]?.count)! - 1].time,
                                        matchDocID: match.docID
                                    )
                                    
                                    self?.matches.append(newUCimg)
                                    self?.sortMatches()
                                    
                                    self?.addMatchUserCoreAndProfileImg(uc, img)
                                }
                            } else {
                                let newUCimg = MatchedUserCore(
                                    uc: uc,
                                    profileImg: img,
                                    timeMatched: match.timeMatched,
                                    lastMessage: n[(self?.snaps[uc.userBasic.uid]?.count)! - 1].snapID_timestamp,
                                    matchDocID: match.docID
                                )
                                
                                self?.matches.append(newUCimg)
                                self?.sortMatches()
                                
                                self?.addMatchUserCoreAndProfileImg(uc, img)
                            }
                        } else {
                            if let j = self?.messages[uc.userBasic.uid] {
                                let newUCimg = MatchedUserCore(
                                    uc: uc,
                                    profileImg: img,
                                    timeMatched: match.timeMatched,
                                    lastMessage: j[(self?.messages[uc.userBasic.uid]?.count)! - 1].time,
                                    matchDocID: match.docID
                                )
                                
                                self?.matches.append(newUCimg)
                                self?.sortMatches()
                                
                                self?.addMatchUserCoreAndProfileImg(uc, img)
                            } else {
                                let newUCimg = MatchedUserCore(
                                    uc: uc,
                                    profileImg: img,
                                    timeMatched: match.timeMatched,
                                    matchDocID: match.docID
                                )
                                
                                self?.matches.append(newUCimg)
                                self?.sortMatches()
                                
                                self?.addMatchUserCoreAndProfileImg(uc, img)
                            }
                        }
                    } else {
                        
                        if let n = self?.snaps[uc.userBasic.uid] {
                            let newUCimg = MatchedUserCore(
                                uc: uc,
                                profileImg: UIImage(),
                                timeMatched: match.timeMatched,
                                lastMessage: n[(self?.snaps[uc.userBasic.uid]?.count)! - 1].snapID_timestamp,
                                matchDocID: match.docID
                            )
                            
                            self?.matches.append(newUCimg)
                            self?.sortMatches()
                            
                            self?.addMatchUserCoreAndProfileImg(uc, nil)
                        } else {
                            let newUCimg = MatchedUserCore(
                                uc: uc,
                                profileImg: UIImage(),
                                timeMatched: match.timeMatched,
                                matchDocID: match.docID
                            )
                            self?.matches.append(newUCimg)
                            self?.sortMatches()
                            
                            self?.addMatchUserCoreAndProfileImg(uc, nil)
                        }
                    }
                }
            }.store(in: &cancellables)
    }
    
    private func observeMatchUserCore(for match: Match) {
        UserCoreService_Firebase.shared.observeUserCore(with: match.matchedUID) { [weak self] uc in
            if let uc = uc {
                //we've got uc, now update the user in core data
                UserCoreService_CoreData.shared.updateUser(userCore: uc)
                //update the matching uc in self.matches
                for i in 0..<self!.matches.count {
                    if uc.userBasic.uid == self?.matches[i].uc.userBasic.uid {
                        self?.matches[i].uc = uc
                    }
                }
            }
        }
    }
    
    private func observeProfileImage(for match: Match) {
        ProfileImageService_Firebase.shared.observeProfileImage(for: match.matchedUID) { [weak self] img, empty in
            if let img = img {
                //we got the img, so let's place it in the right spot
                for i in 0..<self!.matches.count {
                    if self!.matches[i].uc.userBasic.uid == match.matchedUID {
                        self!.matches[i].profileImg = img
                        ProfileImageService_CoreData.shared.uploadProfileImage(uid: match.matchedUID, img: ImageModel(image: img, index: 0))
                    }
                }
            }
            
            if empty {
                //if the image is nil, the user has deleted their profile image, so lets remove it
                for i in 0..<self!.matches.count {
                    if self!.matches[i].uc.userBasic.uid == match.matchedUID {
                        self!.matches[i].profileImg = nil
                        ProfileImageService_CoreData.shared.deleteProfileImage(uid: match.matchedUID, index: "0")
                    }
                }
            }            
        }
    }
    
    private func getMatchesFromCD() -> [Match]? {
        if let matches = MatchService_CoreData.shared.getMatches(for: AuthService.shared.currentUser!.uid) {
            return matches
        } else {
            return nil
        }
    }
    
    private func addMatchUserCoreAndProfileImg(_ uc: UserCore, _ img: UIImage?) {
        //we need to add the uc and img to coreData
        UserCoreService_CoreData.shared.addNewUser(core: uc)
        
        if let img = img {
            ProfileImageService_CoreData.shared.uploadProfileImage(
                uid: uc.userBasic.uid,
                img: ImageModel(
                    image: img,
                    index: 0
                )
            )
        }
    }
    
}

//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Observe Snaps ------------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsDataStore {
    private func observeSnaps() {
        
        //before we observe all snaps, we need to fetch all the snaps we can from core data
        
        observeSnapsToMe()
        observeSnapsFromMe()
    }
    
    private func observeSnapsToMe() {
        SnapService.shared.observeSnapsToMe() { [weak self] snaps, docChange in
            
            switch docChange {
            case .added:
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
                                var newSnap = Snap(fromID: snap.fromID, toID: snap.toID, snapID_timestamp: snap.snapID_timestamp, openedDate: snap.openedDate, img: i, docID: snap.docID)
                                
                                self?.setNewLastMessage(uid: snap.fromID, date: snap.snapID_timestamp)

                                SnapService_CoreData.shared.addSnap(snap: newSnap)
                                
                                newSnap.img = nil
                                
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
            case .modified:
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
            case .removed:
                //cycle through the snaps received and the snaps we have,
                // if there is a match, remove that snap
                for snap in snaps {
                    if let _ = self?.snaps[snap.fromID] {
                        for i in 0..<self!.snaps[snap.fromID]!.count {
                            if self!.snaps[snap.fromID]![i].docID == snap.docID {
                                SnapService_CoreData.shared.deleteSnap(docID: self!.snaps[snap.fromID]![i].docID)
                                self!.snaps[snap.fromID]!.remove(at: i)
                                SnapService_CoreData.shared.deleteSnap(docID: snap.docID)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deleteSnap(_ snap: Snap) {
        SnapService.shared.deleteSnap(snap: snap)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ChatsDataStore: Failed to delete snap with docID -> \(snap.docID)")
                    print("ChatsDataStore-err: \(e)")
                case .finished:
                    print("ChatsDataStore: Finished deleting snap with docID -> \(snap.docID)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func observeSnapsFromMe() {
        SnapService.shared.observerSnapsfromMe { [weak self] snaps, docChange in
            
            switch docChange {
            case .added:
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
            case .modified:
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
            case .removed:
                //cycle through the snaps received and the snaps we have,
                // if there is a match, remove that snap
                for snap in snaps {
                    if let _ = self?.snaps[snap.toID] {
                        for i in 0..<(self?.snaps[snap.toID]!.count)! {
                            if self?.snaps[snap.toID]![i].snapID_timestamp == snap.snapID_timestamp {
                                self?.snaps[snap.toID]!.remove(at: i)
                                SnapService_CoreData.shared.deleteSnap(docID: snap.docID)
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
        
        getMostRecentMessagesCD()
        
        observeChatsFromMe()
        observeChatsToMe()
    }
    
    private func observeChatsFromMe() {
        MessageService_Firebase.shared.observeChatsFromMe() { [weak self] messages, change in
            switch change {
            case .added:
                //we want to only store the most recent message for the receipt
                // everything else is stored in core data
                
                for message in messages {
                    
                    MessageService_CoreData.shared.addMessage(msg: message)
                    
                    self?.setNewLastMessage(uid: message.toID, date: message.time)
                    self?.checkForAnyOpenedSnapsAndDelete(message.toID)
                    
                    if let _ = self?.messages[message.toID] {
                        let insertIndex = self?.messages[message.toID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
                        self?.messages[message.toID]?.insert(message, at: insertIndex!)
                        
                        //After each insertion we will then delete all other values in the array, only leaving the most recent
                        if let last = self?.messages[message.fromID]?.last {
                            self?.messages[message.fromID] = [last]
                        }
                        
                        print("ChatsDataStore: Fetched message from me (appended): \(message.message)")
                        
                    } else {
                        self?.messages[message.toID] = [message]
                        print("ChatsDataStore: Fetched message from me (created): \(message.message)")
                    }
                }
            case .modified:
                for message in messages {
                    MessageService_CoreData.shared.updateMessage(message: message)
                    
                    if let _ = self?.messages[message.toID] {
                        for i in 0..<(self?.messages[message.toID]!.count)! {
                            if self?.messages[message.toID]![i].docID == message.docID {
                                print("ChatsDataStore: Modified message")
                                self?.messages[message.toID]![i] = message
                            }
                        }
                    }
                }
            case .removed:
                print("")
            }
        }
    }
    
    private func observeChatsToMe() {
        MessageService_Firebase.shared.observeChatsToMe() { [weak self] messages, change in
            switch change {
            case .added:
                for message in messages {
                    self?.setNewLastMessage(uid: message.fromID, date: message.time)
                    
                    MessageService_CoreData.shared.addMessage(msg: message)
                    
                    if let _ = self?.messages[message.fromID] {
                        let insertIndex = self?.messages[message.fromID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
                        
                        self?.messages[message.fromID]?.insert(message, at: insertIndex!)
                        
                        //After each insertion we will then delete all other values in the array, only leaving the most recent
                        if let last = self?.messages[message.fromID]?.last {
                            self?.messages[message.fromID] = [last]
                        }
                        
                        print("ChatsDataStore: Fetched message to me (appended): \(message.message)")
                    } else {
                        self?.messages[message.fromID] = [message]
                        print("ChatsDataStore: Fetched message to me (created): \(message.message)")
                    }
                }
            case .modified:
                for message in messages {
                    print("Modified message to me")
                    if let _ = self?.messages[message.fromID] {
                        
                        MessageService_CoreData.shared.updateMessage(message: message)
                        
                        for i in 0..<(self?.messages[message.fromID]!.count)! {
                            if self?.messages[message.fromID]![i].docID == message.docID {
                                self?.messages[message.fromID]![i] = message
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
                    if let _ = self.messages[message.toID] {
                        if self.messages[message.toID]![self.messages[message.toID]!.count - 1].time < message.time {
                            self.messages[message.toID]?.removeAll()
                            self.messages[message.toID]?.append(message)
                        }
                    } else {
                        self.messages[message.toID] = [message]
                    }
                } else if message.toID == AuthService.shared.currentUser!.uid {
                    if let _ = self.messages[message.fromID] {
                        if self.messages[message.fromID]![self.messages[message.fromID]!.count - 1].time < message.time {
                            self.messages[message.fromID]?.removeAll()
                            self.messages[message.fromID]?.append(message)
                        }
                    } else {
                        self.messages[message.fromID] = [message]
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
