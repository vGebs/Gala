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

class ChatsViewModel: ObservableObject {
    
    private var cancellables: [AnyCancellable] = []
    
    private let db = Firestore.firestore()
    
    @Published private(set) var matches: [MatchedUserCore] = []
    @Published private(set) var snaps: OrderedDictionary<String, [Snap]> = [:]
    @Published var matchMessages: OrderedDictionary<String, [Message]> = [:] //Key = uid, value = [message]
    
    init() {
        observeSnaps()
        observeMatches()
        observeChats()
    }
    
    func openSnap(snap: Snap) {
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
                                let newUCimg = MatchedUserCore(uc: uc, profileImg: img, timeMatched: match.timeMatched)
                                self?.matches.append(newUCimg)
                            } else {
                                let newUCimg = MatchedUserCore(uc: uc, profileImg: UIImage(), timeMatched: match.timeMatched)
                                self?.matches.append(newUCimg)
                            }
                        }
                    }.store(in: &self!.cancellables)
            }
        }
    }
    
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
}
