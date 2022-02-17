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
    @Published var matchMessages: OrderedDictionary<String, [Message]> = [:] //Key = uid, value = [message]
    
    init() {
        observeMatches() { [weak self] matches in
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
                    } receiveValue: { uc, img in
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
        
        observeChats()
    }
    
    private func observeMatches(completion: @escaping ([Match]) -> Void) {
        db.collection("Matches")
            .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                var final: [Match] = []

                documentSnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        print("data chatsViewModel: \(data)")
                        let timestamp = data["time"] as? Timestamp
                        
                        if let matchDate = timestamp?.dateValue(){
                            if let uids = data["matched"] as? [String] {
                                for uid in uids {
                                    if uid != AuthService.shared.currentUser!.uid {
                                        print("Matches: \(uid)")
                                        //let temp = SmallUserViewModel(uid: uid)
                                        let match = Match(matchedUID: uid, timeMatched: matchDate)
                                        final.append(match)
                                        print("ChatsViewModel: Added new match: \(uid)")
                                    }
                                }
                            }
                        }
                    }
                })
                
                //self?.matches = final
                completion(final)
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
                    if change.type == .added {
                        let data = change.document.data()
                                                
                        let fromID = data["fromID"] as? String ?? ""
                        let toID = data["toID"] as? String ?? ""
                        let message = data["message"] as? String ?? ""
                        let opened = data["opened"] as? Bool ?? false
                        let timestamp = data["timestamp"] as? Timestamp
                        
                        if let date = timestamp?.dateValue() {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, opened: opened, docID: change.document.documentID)
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
                    
                    if change.type == .modified {
                        let data = change.document.data()
                                                
                        let fromID = data["fromID"] as? String ?? ""
                        let toID = data["toID"] as? String ?? ""
                        let message = data["message"] as? String ?? ""
                        let opened = data["opened"] as? Bool ?? false
                        let timestamp = data["timestamp"] as? Timestamp
                        
                        if let date = timestamp?.dateValue() {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, opened: opened, docID: change.document.documentID)
                            
                            if let _ = self?.matchMessages[toID] {
                                for i in 0..<(self?.matchMessages[toID]!.count)! {
                                    if self?.matchMessages[toID]![i].docID == change.document.documentID {
                                        self?.matchMessages[toID]![i] = message
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
                        let opened = data["opened"] as? Bool ?? false
                        let timestamp = data["timestamp"] as? Timestamp
                        
                        if let date = timestamp?.dateValue() {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, opened: opened, docID: change.document.documentID)
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
                    
                    if change.type == .modified {
                        
                        let data = change.document.data()
                                                
                        let fromID = data["fromID"] as? String ?? ""
                        let toID = data["toID"] as? String ?? ""
                        let message = data["message"] as? String ?? ""
                        let opened = data["opened"] as? Bool ?? false
                        let timestamp = data["timestamp"] as? Timestamp
                        
                        if let date = timestamp?.dateValue() {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, opened: opened, docID: change.document.documentID)
                            
                            if let _ = self?.matchMessages[fromID] {
                                for i in 0..<(self?.matchMessages[fromID]!.count)! {
                                    if self?.matchMessages[fromID]![i].docID == change.document.documentID {
                                        self?.matchMessages[fromID]![i] = message
                                    }
                                }
                            }
                        }
                    }
                })
            }
    }
    
    func openMessage(message: Message) {
        //we want to open the last message only since we are only checking the value of the most recent message
        db.collection("Messages").document(message.docID)
            .updateData(["opened": true]) { err in
                if let e = err {
                    print("ChatsViewModel: Failed to update document")
                    print("ChatsViewModel-err: \(e)")
                } else {
                    print("ChatsViewModel: Successfully updated document")
                }
            }
    }
}
