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
import SwiftUI

class ChatsDataStore: ObservableObject {
    
    static let shared = ChatsDataStore()
    
    private let db = Firestore.firestore()
    
    @Published private(set) var matches: [MatchedUserCore] = []
    @Published private(set) var snaps: OrderedDictionary<String, [Snap]> = [:]
    @Published private(set) var messages: OrderedDictionary<String, [Message]> = [:] //Key = uid, value = [message]
    @Published private(set) var tempMessages: [Message] = []
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {
        //self.initializer()
        
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
    
    func getTempMessages(uid: String) {
        if let msgs = MessageService_CoreData.shared.getAllMessages(fromUserWith: uid) {
            //we need to filter out outdated messages
            
            var oldOpenedMessage: Date?
            
            for message in msgs {
                if message.openedDate != nil {
                    if let diff = Calendar.current.dateComponents([.hour], from: message.openedDate!, to: Date()).hour, diff >= 24 {
                        if oldOpenedMessage == nil {
                            oldOpenedMessage = message.openedDate
                        } else if oldOpenedMessage! < message.openedDate! {
                            oldOpenedMessage = message.openedDate
                        }
                    }
                }
            }
            
            if let o = oldOpenedMessage {
                self.tempMessages = msgs.filter { $0.time > o }
            } else {
                self.tempMessages = msgs
            }
            
        } else {
            self.tempMessages = []
        }
    }
    
    func clearTempMessages() {
        self.tempMessages = []
    }
    
    func unMatchUser(with uid: String) {
        var docID: String = ""
        
        for match in matches {
            if match.uc.userBasic.uid == uid {
                docID = match.matchDocID
            }
        }
        
        if docID != "" {
            MatchService_Firebase.shared.unMatchUser(with: docID, and: uid)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ChatsDataStore: Failed to unMatch user with uid: \(uid)")
                        print("ChatsDataStore-err: \(e)")
                    case .finished:
                        print("ChatsDataStore: Finished unMatching from user w/ uid -> \(uid)")
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
}


//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Observe Matches ----------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsDataStore {
    
    public func isMatch(uid: String?) -> Bool {
        if let uid = uid {
            return matches.contains { $0.uc.userBasic.uid == uid }
        } else {
            return false
        }
    }
    
    private func observeMatches() {
        
//        if let matches = getMatchesFromCD() {
//            for match in matches {
//                getMatchProfile(match)
//                observeMatchUserCore(for: match)
//                observeProfileImage(for: match)
//            }
//        }
        
        MatchService_Firebase.shared.observeMatches() { [weak self] matches in
            
            var alreadyAdded: [String: Match] = [:]
            
            for match in matches {
                if let change = match.changeType{
                    switch change {
                    case .added:
                        
                        for alreadyAddedMatch in self!.matches {
                            if match.docID == alreadyAddedMatch.matchDocID {
                                // it is already added, so flag it
                                alreadyAdded[match.docID] = match
                            }
                        }
                        
                        if alreadyAdded[match.docID] == nil {
                            MatchService_CoreData.shared.addMatch(match: match)
                            self!.getMatchProfile(match)
                            self!.observeMatchUserCore(for: match)
                            self!.observeProfileImage(for: match)
                        }
                        
                    case .modified:
                        //A match should never be modified, it should only be added and removed
                        print("")
                        
                    case .removed:
                        for i in 0..<self!.matches.count {
                            
                            if self!.matches[i].uc.userBasic.uid == match.matchedUID {
                                
                                //Call these functions async
                                DispatchQueue.global(qos: .userInitiated).async {
                                    MatchService_CoreData.shared.deleteMatch(for: match.matchedUID)
                                }
                                
                                DispatchQueue.global(qos: .userInitiated).async {
                                    MessageService_CoreData.shared.deleteMessages(from: match.matchedUID)
                                }
                                
                                DispatchQueue.global(qos: .userInitiated).async {
                                    ProfileService.shared.deleteProfile(for: match.matchedUID)
                                }
                                
                                DispatchQueue.global(qos: .userInitiated).async {
                                    SnapService_CoreData.shared.deleteSnaps(from: match.matchedUID)
                                }
                                
                                print("ChatsDataStore: removing user with uid -> \(match.matchedUID)")
                                self!.matches.remove(at: i)
                                return
                            }
                        }
                    }
                }
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
        SnapService.shared.observeSnapsToMe() { [weak self] snaps in
            
            for snap in snaps {
                if let change = snap.changeType {
                    switch change {
                    case .added:
                        if snap.openedDate == nil {
                            SnapService.shared.fetchSnapAsset(snapID: snap.snapID_timestamp, fromID: snap.fromID, isImage: snap.isImage)
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
                                } receiveValue: { [weak self] imgData, vidURL in
                                    if let assetData = imgData {
                                        var newSnap = Snap(fromID: snap.fromID, toID: snap.toID, snapID: snap.snapID_timestamp, openedDate: snap.openedDate, imgAssetData: assetData, isImage: snap.isImage, docID: snap.docID)
                                        
                                        self?.setNewLastMessage(uid: snap.fromID, date: snap.snapID_timestamp)
                                        
                                        if let caption = snap.caption {
                                            
                                            let newCaption = Caption(
                                                captionText: caption.captionText,
                                                textBoxHeight: caption.textBoxHeight,
                                                yCoordinate: caption.yCoordinate
                                            )
                                            
                                            newSnap.caption = newCaption
                                        }
                                        
                                        SnapService_CoreData.shared.addSnap(snap: newSnap)
                                        
                                        newSnap.imgAssetData = nil
                                        
                                        if let _ = self?.snaps[snap.fromID] {
                                            let insertIndex = self?.snaps[snap.fromID]!.insertionIndexOf(newSnap, isOrderedBefore: {$0.snapID_timestamp < $1.snapID_timestamp})
                                            
                                            self?.snaps[snap.fromID]?.insert(newSnap, at: insertIndex!)
                                            
                                        } else {
                                            self?.snaps[snap.fromID] = [newSnap]
                                        }
                                    } else if let vidURL = vidURL {
                                        var newSnap = Snap(fromID: snap.fromID, toID: snap.toID, snapID: snap.snapID_timestamp, openedDate: snap.openedDate, vidURL: vidURL, isImage: snap.isImage, docID: snap.docID)
                                        
                                        self?.setNewLastMessage(uid: snap.fromID, date: snap.snapID_timestamp)
                                        
                                        if let caption = snap.caption {
                                            
                                            let newCaption = Caption(
                                                captionText: caption.captionText,
                                                textBoxHeight: caption.textBoxHeight,
                                                yCoordinate: caption.yCoordinate
                                            )
                                            
                                            newSnap.caption = newCaption
                                        }
                                        
                                        SnapService_CoreData.shared.addSnap(snap: newSnap)
                                        
                                        if let _ = self?.snaps[snap.fromID] {
                                            let insertIndex = self?.snaps[snap.fromID]!.insertionIndexOf(newSnap, isOrderedBefore: {$0.snapID_timestamp < $1.snapID_timestamp})
                                            
                                            self?.snaps[snap.fromID]?.insert(newSnap, at: insertIndex!)
                                            
                                        } else {
                                            self?.snaps[snap.fromID] = [newSnap]
                                        }
                                    } else {
                                        var newSnap = Snap(fromID: snap.fromID, toID: snap.toID, snapID: snap.snapID_timestamp, openedDate: snap.openedDate, isImage: snap.isImage, docID: snap.docID)
                                        
                                        self?.setNewLastMessage(uid: snap.fromID, date: snap.snapID_timestamp)
                                        
                                        if let caption = snap.caption {
                                            
                                            let newCaption = Caption(
                                                captionText: caption.captionText,
                                                textBoxHeight: caption.textBoxHeight,
                                                yCoordinate: caption.yCoordinate
                                            )
                                            
                                            newSnap.caption = newCaption
                                        }
                                        
                                        if let _ = self?.snaps[snap.fromID] {
                                            let insertIndex = self?.snaps[snap.fromID]!.insertionIndexOf(newSnap, isOrderedBefore: {$0.snapID_timestamp < $1.snapID_timestamp})
                                            
                                            self?.snaps[snap.fromID]?.insert(newSnap, at: insertIndex!)
                                            
                                        } else {
                                            self?.snaps[snap.fromID] = [newSnap]
                                        }
                                    }
                                    
                                    var oldOpenedMessage: Date?
                                    
                                    if let messages = self?.messages[snap.fromID] {
                                        for message in messages {
                                            if message.openedDate != nil {
                                                if let diff = Calendar.current.dateComponents([.hour], from: message.openedDate!, to: Date()).hour, diff >= 24 {
                                                    if oldOpenedMessage == nil {
                                                        oldOpenedMessage = message.openedDate
                                                    } else if oldOpenedMessage! < message.openedDate! {
                                                        oldOpenedMessage = message.openedDate
                                                    }
                                                }
                                            }
                                        }
                                        
                                        //now we filter out all messages older than the oldOpenedDate
                                        if let newestOpenedMessage = oldOpenedMessage {
                                            self!.checkForAnyOpenedMessagesAndDelete(snap.fromID, date: newestOpenedMessage, docID: "")
                                        }
                                    }
                                    
                                }
                                .store(in: &self!.cancellables)
                        } else {
                            var newSnap = Snap(fromID: snap.fromID, toID: snap.toID, snapID: snap.snapID_timestamp, openedDate: snap.openedDate, isImage: snap.isImage, docID: snap.docID)
                            
                            self?.setNewLastMessage(uid: snap.fromID, date: snap.snapID_timestamp)
                            
                            if let caption = snap.caption {
                                
                                let newCaption = Caption(
                                    captionText: caption.captionText,
                                    textBoxHeight: caption.textBoxHeight,
                                    yCoordinate: caption.yCoordinate
                                )
                                
                                newSnap.caption = newCaption
                            }
                            
                            if let _ = self?.snaps[snap.fromID] {
                                let insertIndex = self?.snaps[snap.fromID]!.insertionIndexOf(newSnap, isOrderedBefore: {$0.snapID_timestamp < $1.snapID_timestamp})
                                
                                self?.snaps[snap.fromID]?.insert(newSnap, at: insertIndex!)
                                
                            } else {
                                self?.snaps[snap.fromID] = [newSnap]
                            }
                        }
                        
                        
                    case .modified:
                        SnapService_CoreData.shared.updateSnap(snap)
                        
                        if let _ = self?.snaps[snap.fromID] {
                            
                            //test this
                            if let i = self?.snaps[snap.fromID]?.firstIndex(where: { $0.docID == snap.docID }) {
                                self?.snaps[snap.fromID]?[i] = snap
                                print("ChatsDataStore: modified snap with id -> \(snap.docID)")
                            }
                        }
                    case .removed:
                        SnapService_CoreData.shared.deleteSnap(snap)
                        
                        if let _ = self?.snaps[snap.fromID] {
                            self?.snaps[snap.fromID] = self?.snaps[snap.fromID]?.filter { $0.docID != snap.docID }
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
        SnapService.shared.observerSnapsfromMe { [weak self] snaps in
            
            for snap in snaps {
                if let change = snap.changeType {
                    switch change {
                    case .added:
                        self?.setNewLastMessage(uid: snap.toID, date: snap.snapID_timestamp)

                        //SnapService_CoreData.shared.addSnap(snap: snap)
                        
                        if let _ = self?.snaps[snap.toID] {
                            let insertIndex = self?.snaps[snap.toID]!.insertionIndexOf(snap, isOrderedBefore: {$0.snapID_timestamp < $1.snapID_timestamp})
                            
                            self?.snaps[snap.toID]?.insert(snap, at: insertIndex!)
                            
                        } else {
                            self?.snaps[snap.toID] = [snap]
                        }
                        
                        //we added the new snap, now we need to make sure there isnt any messages left that are older than 24hrs
                        var oldOpenedMessage: Date?
                        
                        if let messages = self?.messages[snap.toID] {
                            for message in messages {
                                if message.openedDate != nil {
                                    if let diff = Calendar.current.dateComponents([.hour], from: message.openedDate!, to: Date()).hour, diff >= 24 {
                                        if oldOpenedMessage == nil {
                                            oldOpenedMessage = message.openedDate
                                        } else if oldOpenedMessage! < message.openedDate! {
                                            oldOpenedMessage = message.openedDate
                                        }
                                    }
                                }
                            }
                            
                            //now we filter out all messages older than the oldOpenedDate
                            if let newestOpenedMessage = oldOpenedMessage {
                                self!.checkForAnyOpenedMessagesAndDelete(snap.toID, date: newestOpenedMessage, docID: "")
                            }
                        }
                        
                        
                    case .modified:
                        
                        //SnapService_CoreData.shared.updateSnap(snap)
                        
                        if let _ = self?.snaps[snap.toID] {
                            if let i = self?.snaps[snap.toID]?.firstIndex(where: { $0.docID == snap.docID }) {
                                self?.snaps[snap.toID]?[i] = snap
                                print("ChatsDataStore: modified snap with id -> \(snap.docID)")
                            }
                        }
                        
                    case .removed:
                        //SnapService_CoreData.shared.deleteSnap(snap)
                        
                        if let _ = self?.snaps[snap.toID] {
                            self?.snaps[snap.toID] = self?.snaps[snap.toID]!.filter { $0.docID != snap.docID }
                            print("ChatsDataStore: Removed snap with docID: \(snap.docID)")
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
        //we are setting the most recent message for all of our matches
        setMostRecentMessagesFromCD()
        
        //As we enter the app, we should check for messages in core data that have been opened for longer that 24hrs, we then delete all messages that are older than 24hrs
        
        if let matches = getMatchesFromCD() {
            for match in matches {
                //we also need to get observe every most recent message from that user
                deleteOutDatedMessages(for: match.matchedUID)
                if let mostRecentMessage = MessageService_CoreData.shared.getMostRecentMessage(for: match.matchedUID){
                    observeMessage(mostRecentMessage)
                }
            }
        }
        
//        1. Is it opened?
//             - if no, add it
//             - if yes, #2
//        2. How long ago was it opened?
//             - if it is less than 24hrs, keep it
//             - else #3
//        3. Is it the most recent message/snap
//             - if its not, delete it
//             - if it is,
//                  - remove all messages that are older than the openedDate
//                  - then add it
        
        if let newestMessageDate = getNewestMessageDate() {
            observeChatsFromMe(olderThan: newestMessageDate)
            observeChatsToMe(olderThan: newestMessageDate)
        } else {
            observeChatsFromMe(olderThan: Date("2020-06-12"))
            observeChatsToMe(olderThan: Date("2020-06-12"))
        }
    }
    
    private func observeMessage(_ msg: Message) {
        MessageService_Firebase.shared.observeMessage(for: msg.docID) { [weak self] message in
            if let message = message {
                //update
                MessageService_CoreData.shared.updateMessage(message: message)
                if message.fromID == AuthService.shared.currentUser!.uid {
                    if let messages = self?.messages[message.toID] {
                        for i in 0..<messages.count {
                            if messages[i].docID == msg.docID {
                                self?.messages[message.toID]![i] = message
                            }
                        }
                    } else {
                        self?.messages[message.toID] = [message]
                    }
                } else {
                    if let messages = self?.messages[message.fromID] {
                        for i in 0..<messages.count {
                            if messages[i].docID == msg.docID {
                                self?.messages[message.fromID]![i] = message
                            }
                        }
                    } else {
                        self?.messages[message.fromID] = [message]
                    }
                }
            } else {
                //remove
                MessageService_CoreData.shared.deleteMessage(with: msg.docID)
                if msg.fromID == AuthService.shared.currentUser!.uid {
                    if let _ = self?.messages[msg.toID] {
                        self?.messages[msg.toID] = self?.messages[msg.toID]!.filter { $0.docID != msg.docID }
                        self?.tempMessages = self!.tempMessages.filter { $0.docID != msg.docID }
                    }
                } else {
                    if let _ = self?.messages[msg.fromID] {
                        self?.messages[msg.fromID] = self?.messages[msg.fromID]!.filter { $0.docID != msg.docID }
                        self?.tempMessages = self!.tempMessages.filter { $0.docID != msg.docID }
                        
                    }
                }
            }
        }
    }
    
    private func deleteOutDatedMessages(for uid: String) {
        var oldOpenedMessage: Date?
        var docID: String?
        if let messages = MessageService_CoreData.shared.getAllMessages(fromUserWith: uid) {
            for message in messages {
                if message.openedDate != nil {
                    if let diff = Calendar.current.dateComponents([.hour], from: message.openedDate!, to: Date()).hour, diff >= 24 {
                        if oldOpenedMessage == nil {
                            oldOpenedMessage = message.openedDate
                            docID = message.docID
                        } else if oldOpenedMessage! < message.openedDate! {
                            oldOpenedMessage = message.openedDate
                            docID = message.docID
                        }
                    }
                }
            }
            
            //now we filter out all messages older than the oldOpenedDate
            if let newestOpenedMessage = oldOpenedMessage {
                self.checkForAnyOpenedMessagesAndDelete(uid, date: newestOpenedMessage, docID: docID!)
            }
        }
    }
    
    private func getNewestMessageDate() -> Date? {
        if let messages = MessageService_CoreData.shared.getAllMessages() {
            var newestDate: Date?
            
            //we want to get the most recent message, openedDate does not matter
            // OpenedDate does not matter because we are querying for chats that have a greater sent date
            // We also need to be able to observe the most recent chat for updates because we only care about listening in on the most recent message
            // we only care about listening to the most recent message because if it is read/opened we need to update the object so we know which messages to delete in the future
            
            for message in messages {
                if newestDate == nil {
                    newestDate = message.time
                } else {
                    if newestDate! < message.time {
                        newestDate = message.time
                    }
                }
            }
            
            return newestDate
        } else {
            return nil
        }
    }
    
    private func observeChatsFromMe(olderThan date: Date) {
        MessageService_Firebase.shared.observeChatsFromMe(olderThan: date) { [weak self] messages in
            
            for message in messages {
                if let change = message.changeType {
                    switch change {
                    case .added:
                        
                        if let openedDate = message.openedDate {
                            //it is opened, now is it older than 24hrs

                            if let diff = Calendar.current.dateComponents([.hour], from: openedDate, to: Date()).hour, diff >= 24 {
                                //it is older than 24hrs
                                //check to see if it was the last form of communication, is so, we add it
                                if self!.isMostRecent(message.time, uid: message.toID) {
                                    //if it is the most recent, we delete all open messages
                                    self?.checkForAnyOpenedMessagesAndDelete(message.toID, date: openedDate, docID: message.docID)
                                    //we then add it
                                    self?.addNewMessageFromMe(message)
                                } else {
                                    self?.deleteMessage(message)
                                }
                                
                            } else {
                                //it is not older than 24hrs, keep it (we keep messages for 24 hours then delete them)
                                //if we get a new message in chat while the app is opened, we must check if there is any outstanding openedChats and delete them
                                self?.checkForAnyOpenedMessagesAndDelete(message.toID, date: message.time, docID: message.docID)
                                self!.addNewMessageFromMe(message)
                            }

                        } else {
                            //before we add a new message that hasnt been opened, we have to make sure that there is no opened messages older than 24hrs and if there is, delete that message and all messages that are sent before the opened date
                            
                            var oldOpenedMessage: Date?
                            
                            if let messages = self?.messages[message.toID] {
                                for message in messages {
                                    if message.openedDate != nil {
                                        if let diff = Calendar.current.dateComponents([.hour], from: message.openedDate!, to: Date()).hour, diff >= 24 {
                                            if oldOpenedMessage == nil {
                                                oldOpenedMessage = message.openedDate
                                            } else if oldOpenedMessage! < message.openedDate! {
                                                oldOpenedMessage = message.openedDate
                                            }
                                        }
                                    }
                                }
                                
                                //now we filter out all messages older than the oldOpenedDate
                                if let newestOpenedMessage = oldOpenedMessage {
                                    self!.checkForAnyOpenedMessagesAndDelete(message.toID, date: newestOpenedMessage, docID: message.docID)
                                }
                            }
                            
                            self!.addNewMessageFromMe(message)
                        }
                        
                    case .modified:
                        
                        MessageService_CoreData.shared.updateMessage(message: message)
                        
                        if let _ = self?.messages[message.toID] {
                            for i in 0..<self!.messages[message.toID]!.count {
                                if self?.messages[message.toID]![i].docID == message.docID {
                                    self?.messages[message.toID]![i] = message
                                    print("ChatsDataStore: Modified message")
                                }
                            }
                        }
                        
                        for i in 0..<self!.tempMessages.count {
                            if self?.tempMessages[i].docID == message.docID {
                                self?.tempMessages[i] = message
                            }
                        }
                        
                    case .removed:
                        
                        MessageService_CoreData.shared.deleteMessage(with: message.docID)
                        
                        self?.tempMessages = self!.tempMessages.filter { $0.docID != message.docID }
                        
                        if let _ = self?.messages[message.toID] {
                            self?.messages[message.toID] = self?.messages[message.toID]!
                                .filter { $0.docID != message.docID }
                        }
                    }
                }
            }
        }
    }
    
    private func observeChatsToMe(olderThan date: Date) {
        MessageService_Firebase.shared.observeChatsToMe(olderThan: date) { [weak self] messages in
            
            for message in messages {
                if let change = message.changeType {
                    switch change {
                    case .added:
                        
                        if let openedDate = message.openedDate { //DONE
                            //it is opened, now is it older than 24hrs

                            if let diff = Calendar.current.dateComponents([.hour], from: openedDate, to: Date()).hour, diff >= 24 {
                                //it is older than 24hrs
                                //check to see if it was the last form of communication, is so, we add it
                                if self!.isMostRecent(message.time, uid: message.fromID) {
                                    //if it is the most recent, we delete all open messages
                                    self?.checkForAnyOpenedMessagesAndDelete(message.fromID, date: openedDate, docID: message.docID)
                                    //we then add it
                                    self?.addNewMessageToMe(message)
                                } else {
                                    self?.deleteMessage(message)
                                }
                                
                            } else { //DONE
                                //it is not older than 24hrs, keep it (we keep messages for 24 hours then delete them)
                                self!.addNewMessageToMe(message)
                            }

                        } else { //DONE
                            //before we add a new message that hasnt been opened, we have to make sure that there is no opened messages older than 24hrs and if there is, delete that message and all messages that are sent before the opened date
                            
                            var oldOpenedMessage: Date?
                            
                            if let messages = self?.messages[message.fromID] {
                                for message in messages {
                                    if message.openedDate != nil {
                                        if let diff = Calendar.current.dateComponents([.hour], from: message.openedDate!, to: Date()).hour, diff >= 24 {
                                            if oldOpenedMessage == nil {
                                                oldOpenedMessage = message.openedDate
                                            } else if oldOpenedMessage! < message.openedDate! {
                                                oldOpenedMessage = message.openedDate
                                            }
                                        }
                                    }
                                }
                                
                                //now we filter out all messages older than the oldOpenedDate
                                if let newestOpenedMessage = oldOpenedMessage {
                                    self!.checkForAnyOpenedMessagesAndDelete(message.fromID, date: newestOpenedMessage, docID: message.docID)
                                }
                            }
                            
                            self!.addNewMessageToMe(message)
                        }
                        
                    case .modified:
                        
                        MessageService_CoreData.shared.updateMessage(message: message)
                        
                        if let _ = self?.messages[message.fromID] {
                            for i in 0..<(self?.messages[message.fromID]!.count)! {
                                if self?.messages[message.fromID]![i].docID == message.docID {
                                    self?.messages[message.fromID]![i] = message
                                    print("ChatsDataStore: Modified message")
                                }
                            }
                        }
                        
                        for i in 0..<self!.tempMessages.count {
                            if self?.tempMessages[i].docID == message.docID {
                                self?.tempMessages[i] = message
                            }
                        }
                        
                    case .removed:
                        
                        MessageService_CoreData.shared.deleteMessage(with: message.docID)
                        
                        self?.tempMessages = self!.tempMessages.filter { $0.docID != message.docID }

                        //because we are only keeping the most recent message from each person, this filter shouldn't do much, unless it is deleted the most recent snap
                        if let _ = self?.messages[message.fromID] {
                            self?.messages[message.fromID] = self?.messages[message.fromID]!
                                .filter { $0.docID != message.docID }
                        }
                    }
                }
            }
        }
    }
    
    private func setMostRecentMessagesFromCD() {
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
    
    private func addNewMessageFromMe(_ message: Message) {
        MessageService_CoreData.shared.addMessage(msg: message)
        
        self.setNewLastMessage(uid: message.toID, date: message.time)
        self.checkForAnyOpenedSnapsAndDelete(message.toID)
        
        if let _ = self.messages[message.toID] {
            let insertIndex = self.messages[message.toID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
            self.messages[message.toID]?.insert(message, at: insertIndex)
            
            //After each insertion we will then delete all other values in the array, only leaving the most recent
            if let last = self.messages[message.toID]?.last {
                self.messages[message.toID] = [last]
            }
            
            print("ChatsDataStore: Fetched message from me (appended): \(message.message)")
            
        } else {
            self.messages[message.toID] = [message]
            print("ChatsDataStore: Fetched message from me (created): \(message.message)")
        }
    }
    
    private func addNewMessageToMe(_ message: Message) {
        self.setNewLastMessage(uid: message.fromID, date: message.time)
        
        MessageService_CoreData.shared.addMessage(msg: message)
        
        if let _ = self.messages[message.fromID] {
            let insertIndex = self.messages[message.fromID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
            
            self.messages[message.fromID]?.insert(message, at: insertIndex)
            
            //After each insertion we will then delete all other values in the array, only leaving the most recent
            if let last = self.messages[message.fromID]?.last {
                self.messages[message.fromID] = [last]
            }
            
            print("ChatsDataStore: Fetched message to me (appended): \(message.message)")
        } else {
            self.messages[message.fromID] = [message]
            print("ChatsDataStore: Fetched message to me (created): \(message.message)")
        }
        
        var isCurrentConvo = false
        
        for i in 0..<self.tempMessages.count {
            if self.tempMessages[i].fromID == message.fromID || self.tempMessages[i].toID == message.fromID {
                isCurrentConvo = true
            }
        }
        
        if isCurrentConvo {
            let insertIndex = self.tempMessages.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
            
            self.tempMessages.insert(message, at: insertIndex)
        }
    }
    
    private func isMostRecent(_ time: Date, uid: String) -> Bool {
        
        func isMessageMoreRecent(_ time: Date, uid: String) -> Bool {
            
            if let msgs = self.messages[uid] {
                for msg in msgs {
                    if msg.time > time {
                        //the message is newer, so remove all opened messages
                        return false
                    }
                }
                return true
            }
            return true
        }
        
        func isMoreRecentSnap(_ time: Date, uid: String) -> Bool {
            if let snaps = self.snaps[uid] {
                for snap in snaps {
                    if snap.snapID_timestamp > time {
                        //the message is newer, so remove all opened messages
                        return false
                    }
                }
                return true
            }
            return true
        }
        
        //let val = isMessageMoreRecent(time, uid: uid) && isMoreRecentSnap(time, uid: uid)
        
        return isMessageMoreRecent(time, uid: uid) && isMoreRecentSnap(time, uid: uid)
    }
    
    private func deleteMessage(_ message: Message) {
        MessageService_Firebase.shared.deleteMessage(message: message)
            .sink { completion in
                switch completion {
                case .finished:
                    print("ChatsDataStore: Finished deleting old message")
                case .failure(let e):
                    print("ChatsDataStore: Failed to delete old message")
                    print("ChatsDataStore-err: \(e)")
                }
            } receiveValue: { _ in
                MessageService_CoreData.shared.deleteMessage(with: message.docID)
            }
            .store(in: &cancellables)
    }
    
    private func checkForAnyOpenedMessagesAndDelete(_ uid: String, date: Date, docID: String) {
        //Delete all messages that have a time sent older than the lastOpenedDate
        
        if let messages = MessageService_CoreData.shared.getAllMessages(fromUserWith: uid) {
            let toBeDeleted = messages.filter { $0.time < date }
            for message in toBeDeleted {
                if message.docID != docID {
                    self.deleteMessage(message)
                }
            }
        }
        
//        if let _ = self.messages[uid] {
//            let toBeDeleted = self.messages[uid]!.filter { $0.time < date }
//            for message in toBeDeleted {
//                if message.docID != docID {
//                    self.deleteMessage(message)
//                }
//            }
//        }
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
