//
//  ChatsViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Foundation
import Combine
import FirebaseFirestore
import OrderedCollections
import UIKit

class ChatsViewModel: ObservableObject, SnapProtocol {
    
    private var cancellables: [AnyCancellable] = []
    
    private let db = Firestore.firestore()
    
    @Published private(set) var matches: [MatchedUserCore] = []
    @Published var snaps: OrderedDictionary<String, [Snap]> = [:]
    @Published var matchMessages: OrderedDictionary<String, [Message]> = [:] //Key = uid, value = [message]
    @Published var combinedSnapsAndMessages: [Any] = []
    
    @Published var showChat = false
    @Published var userChat: UserChat? = nil
    @Published var timeMatched: Date? = nil
    
    @Published var messageText = ""
    
    init() {
        observeMatches()
        observeSnaps()
        observeChats()
    }
    
    func getUnopenedSnapsFrom(uid: String) -> [Snap] {
        var final: [Snap] = []
        if let snaps = snaps[uid] {
            for snap in snaps {
                if snap.openedDate == nil && snap.fromID != AuthService.shared.currentUser!.uid {
                    final.append(snap)
                }
            }
        }
        return final
    }
    
    func handleConvoPress() {
        //for this function, we need to determine which button was pressed.
        //If there is an unopened snap, we open the snap(s)
        //if there is no snaps, we open the chat
        
    }
    
    func openSnap(snap: Snap) {
        // the first snap will always be opened first (arr[0])
        // we will then delete the meta and the asset only if it is not the most recent message because we need the receipt
        //
        
        if let snaps = snaps[snap.fromID] {
            
            //check to see how many openedSnaps there are
            var unopenedCounter = 0
            
            for snap in snaps {
                if snap.openedDate == nil {
                    unopenedCounter += 1
                }
            }
            
            if unopenedCounter > 1 {
                deleteSnap_(snap)
            } else {
                openSnap_(snap)
            }
        }
    }
    
    private func openSnap_(_ snap: Snap) {
        SnapService.shared.openSnap(snap: snap)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ChatsViewModel: Failed to open snap with docID: \(snap.docID)")
                    print("ChatsViewModel-err: \(e)")
                case .finished:
                    print("ChatsViewModel: Successfully opened snap with docID: \(snap.docID)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func deleteSnap_(_ snap: Snap){
        SnapService.shared.deleteSnap(snap: snap)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ChatsViewModel: Failed to delete snap")
                    print("ChatsViewModel-err: \(e)")
                case .finished:
                    print("ChatsViewModel: Successfully deleted snap")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func openMessage(message: Message) {
        ChatService.shared.openMessage(message: message)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ChatsViewModel: Failed to open message")
                    print("ChatsViewModel-err: \(e)")
                case .finished:
                    print("ChatsViewModel: Successfully opened message")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func sendMessage(toUID: String) {
        //make sure there is at least one character before sending
        
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !messageText.isEmpty && trimmed.count > 0{
            
            ChatService.shared.sendMessage(message: messageText, toID: toUID)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
//                .map { [weak self] _  in
//                    self!.checkForAnyOpenedSnapsAndDelete(toUID)
//                }
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ChatViewModel: Failed to send messgae")
                        print("ChatsViewModel-err: \(e)")
                    case .finished:
                        print("ChatsViewModel: Successfully sent message to -> \(toUID)")
                    }
                } receiveValue: { [weak self] _ in
                    self?.messageText = ""
                }
                .store(in: &cancellables)
        }
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

//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Observe Matches ----------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsViewModel {
    private func observeMatches() {
        MatchService.shared.observeMatches() { [weak self] matches in
            for match in matches {
                Publishers.Zip(
                    UserCoreService.shared.getUserCore(uid: match.matchedUID),
                    ProfileImageService.shared.getProfileImage(id: match.matchedUID, index: "0")
                )
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ChatsViewModel: Failed to fetch uc and img")
                            print("ChatsViewModel-err: \(e)")
                        case .finished:
                            print("ChatsViewModel: Successfully fetched uc and img")
                        }
                    } receiveValue: { [weak self] uc, img in
                        if let uc = uc {
                            if let img = img {
                                
                                if let n = self?.snaps[uc.uid] {
                                    if let j = self?.matchMessages[uc.uid] {
                                        if n[(self?.snaps[uc.uid]?.count)! - 1].snapID_timestamp > j[(self?.matchMessages[uc.uid]?.count)! - 1].time {
                                            
                                            let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched, lastMessage: n[(self?.snaps[uc.uid]?.count)! - 1].snapID_timestamp)
                                            self?.matches.append(newUCimg)
                                            self?.sortMatches()
                                        } else {
                                            
                                            let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched, lastMessage: j[(self?.matchMessages[uc.uid]?.count)! - 1].time)
                                            self?.matches.append(newUCimg)
                                            self?.sortMatches()
                                        }
                                    } else {
                                        let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched, lastMessage: n[(self?.snaps[uc.uid]?.count)! - 1].snapID_timestamp)
                                        
                                        self?.matches.append(newUCimg)
                                        self?.sortMatches()
                                    }
                                } else {
                                    if let j = self?.matchMessages[uc.uid] {
                                        let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched, lastMessage: j[(self?.matchMessages[uc.uid]?.count)! - 1].time)
                                        self?.matches.append(newUCimg)
                                        self?.sortMatches()
                                    } else {
                                        let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched)
                                        self?.matches.append(newUCimg)
                                        self?.sortMatches()
                                    }
                                }
                                
                            } else {
                                
                                if let n = self?.snaps[uc.uid] {
                                    let newUCimg = MatchedUserCore(uc: uc, profileImg: UIImage(), timeMatched: match.timeMatched, lastMessage: n[(self?.snaps[uc.uid]?.count)! - 1].snapID_timestamp)
                                    
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
extension ChatsViewModel {
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
                                print("ChatsViewModel: Failed to fetch snap with id: \(snap.snapID_timestamp)")
                                print("ChatsViewModel-err: \(e)")
                            case .finished:
                                print("ChatsViewModel: Successfully fetched snap")
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
                                print("ChatsViewModel: modified snap with id -> \(snap.docID)")
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
                                print("ChatsViewModel: modified snap with id -> \(snap.docID)")
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
                                print("ChatsViewModel: removed snap with id -> \(snap.docID)")
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
extension ChatsViewModel {
    private func observeChats() {
        observeChatsFromMe()
        observeChatsToMe()
    }
    
    private func observeChatsFromMe() {
        db.collection("Messages")
            .whereField("fromID", isEqualTo: AuthService.shared.currentUser!.uid)
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("ChatsViewModel: Failed to observe chats from me")
                    print("ChatsViewModel-err: \(error!)")
                    return
                }
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                                            
                    let fromID = data["fromID"] as? String ?? ""
                    let toID = data["toID"] as? String ?? ""
                    let message = data["message"] as? String ?? ""
                    let opened = data["openedDate"] as? Timestamp
                    let timestamp = data["timestamp"] as? Timestamp
                    
                    if change.type == .added {
                        if let date = timestamp?.dateValue() {
                            if let o = opened {
                                let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: change.document.documentID)
                                
                                self?.setNewLastMessage(uid: message.toID, date: message.time)
                                self?.checkForAnyOpenedSnapsAndDelete(message.toID)
                                
                                if let _ = self?.matchMessages[toID] {
                                    let insertIndex = self?.matchMessages[toID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
                                    self?.matchMessages[toID]?.insert(message, at: insertIndex!)
                                    print("ChatsViewModel: Fetched message from me (appended): \(message.message)")
                                    
                                } else {
                                    self?.matchMessages[toID] = [message]
                                    print("ChatsViewModel: Fetched message from me (created): \(message.message)")
                                }
                            } else {
                                let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: nil, docID: change.document.documentID)
                                
                                self?.setNewLastMessage(uid: message.toID, date: message.time)
                                self?.checkForAnyOpenedSnapsAndDelete(message.toID)

                                if let _ = self?.matchMessages[toID] {
                                    let insertIndex = self?.matchMessages[toID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
                                    self?.matchMessages[toID]?.insert(message, at: insertIndex!)
                                    print("ChatsViewModel: Fetched message from me (appended): \(message.message)")
                                    
                                } else {
                                    self?.matchMessages[toID] = [message]
                                    print("ChatsViewModel: Fetched message from me (created): \(message.message)")
                                }
                            }
                        }
                        
                    } else if change.type == .modified {
                        if let date = timestamp?.dateValue() {
                            if let o = opened {
                                let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: change.document.documentID)
                                
                                if let _ = self?.matchMessages[toID] {
                                    for i in 0..<(self?.matchMessages[toID]!.count)! {
                                        if self?.matchMessages[toID]![i].docID == change.document.documentID {
                                            self?.matchMessages[toID]![i] = message
                                        }
                                    }
                                }
                            } else {
                                let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: nil, docID: change.document.documentID)
                                
                                if let _ = self?.matchMessages[toID] {
                                    for i in 0..<(self?.matchMessages[toID]!.count)! {
                                        if self?.matchMessages[toID]![i].docID == change.document.documentID {
                                            self?.matchMessages[toID]![i] = message
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
    }
    
    private func observeChatsToMe() {
        db.collection("Messages")
            .whereField("toID", isEqualTo: AuthService.shared.currentUser!.uid)
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("ChatsViewModel: Failed to observe chats from me")
                    print("ChatsViewModel-err: \(error!)")
                    return
                }
                
                documentSnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                                                
                        let fromID = data["fromID"] as? String ?? ""
                        let toID = data["toID"] as? String ?? ""
                        let message = data["message"] as? String ?? ""
                        let opened = data["openedDate"] as? Timestamp
                        let timestamp = data["timestamp"] as? Timestamp
                        
                        if let date = timestamp?.dateValue() {
                            if let o = opened {
                                let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: change.document.documentID)
                                
                                self?.setNewLastMessage(uid: message.fromID, date: message.time)
                                
                                if let _ = self?.matchMessages[fromID] {
                                    let insertIndex = self?.matchMessages[fromID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
                                    
                                    self?.matchMessages[fromID]?.insert(message, at: insertIndex!)
                                    print("ChatsViewModel: Fetched message to me (appended): \(message.message)")
                                } else {
                                    self?.matchMessages[fromID] = [message]
                                    print("ChatsViewModel: Fetched message to me (created): \(message.message)")
                                }
                            } else {
                                let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: nil, docID: change.document.documentID)
                                
                                self?.setNewLastMessage(uid: message.fromID, date: message.time)
                                
                                if let _ = self?.matchMessages[fromID] {
                                    let insertIndex = self?.matchMessages[fromID]!.insertionIndexOf(message, isOrderedBefore: { $0.time < $1.time })
                                    
                                    self?.matchMessages[fromID]?.insert(message, at: insertIndex!)
                                    print("ChatsViewModel: Fetched message to me (appended): \(message.message)")
                                } else {
                                    self?.matchMessages[fromID] = [message]
                                    print("ChatsViewModel: Fetched message to me (created): \(message.message)")
                                }
                            }
                        }
                    }
                    
                    if change.type == .modified {
                        
                        let data = change.document.data()
                                                
                        let fromID = data["fromID"] as? String ?? ""
                        let toID = data["toID"] as? String ?? ""
                        let message = data["message"] as? String ?? ""
                        let opened = data["openedDate"] as? Timestamp
                        let timestamp = data["timestamp"] as? Timestamp
                        
                        if let date = timestamp?.dateValue() {
                            if let o = opened {
                                let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: change.document.documentID)
                                
                                if let _ = self?.matchMessages[fromID] {
                                    for i in 0..<(self?.matchMessages[fromID]!.count)! {
                                        if self?.matchMessages[fromID]![i].docID == change.document.documentID {
                                            self?.matchMessages[fromID]![i] = message
                                            print("ChatsViewModel: Modified message")
                                        }
                                    }
                                }
                            } else {
                                let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: nil, docID: change.document.documentID)
                                
                                if let _ = self?.matchMessages[fromID] {
                                    for i in 0..<(self?.matchMessages[fromID]!.count)! {
                                        if self?.matchMessages[fromID]![i].docID == change.document.documentID {
                                            self?.matchMessages[fromID]![i] = message
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
    }
}

//MARK: ----------------------------------------------------------------------------------------------------------->
//MARK: - Helpers ------------------------------------------------------------------------------------------------->
//MARK: ----------------------------------------------------------------------------------------------------------->
extension ChatsViewModel {
    private func setNewLastMessage(uid: String, date: Date) {
        for i in 0..<self.matches.count {
            if matches[i].uc.uid == uid {
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
}
