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

class ChatsViewModel: ObservableObject {
    
    private var cancellables: [AnyCancellable] = []
    
    private let db = Firestore.firestore()
    
    @Published private(set) var matches: [Match] = []
    @Published var matchMessages: OrderedDictionary<String, [Message]> = [:] //Key = uid, value = [message]
    
    init() {
        observeMatches()
        
        //we need to fetch all messages as well to see when the last message was sent/ recieved and whether it was opened or not.
        //we can store the match messages in a dictionary.
        //  key = uid of matched user
        //  value = array of messages
        observeChats()
    }
    
    private func observeMatches()  {
        db.collection("Matches")
            .whereField("matched", arrayContains: String(AuthService.shared.currentUser!.uid))
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                documentSnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        
                        var final: [Match] = []
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
                        
                        self?.matches = final
                    }
                })
            }
    }
    
    func observeChats() {
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
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, opened: opened)
                            if let _ = self?.matchMessages[toID] {
                                self?.matchMessages[toID]?.append(message)
                                print("ChatsViewModel: Fetched message from me: \(message.message)")
                            } else {
                                self?.matchMessages[toID] = [message]
                                print("ChatsViewModel: Fetched message from me: \(message.message)")
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
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, opened: opened)
                            if let _ = self?.matchMessages[toID] {
                                DispatchQueue.main.async {
                                    self?.matchMessages[fromID]?.append(message)
                                }
                                print("ChatsViewModel: Fetched message to me: \(message.message)")
                            } else {
                                DispatchQueue.main.async {
                                    self?.matchMessages[fromID] = [message]
                                }
                                print("ChatsViewModel: Fetched message to me: \(message.message)")
                            }
                        }
                    }
                })
            }
    }
}
