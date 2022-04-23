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
    
    @Published var tempMessages: [Message] = []
    
    @Published var showChat = false
    @Published var userChat: UserChat? = nil
    @Published var timeMatched: Date? = nil
    
    @Published var messageText = ""
    
    @Published var lastMatchUpdate: Date?
    
    deinit {
        print("ChatsViewModel: Deinitializing")
    }
    
    init() {
        DataStore.shared.chatsData.$matches
            .sink(receiveValue: { [weak self] matches in
                self?.matches = matches
            }).store(in: &cancellables)

        DataStore.shared.chatsData.$snaps
            .sink(receiveValue: { [weak self] snaps in
                self?.snaps = snaps
            }).store(in: &cancellables)
            
        DataStore.shared.chatsData.$matchMessages
            .sink(receiveValue: { [weak self] messages in
                self?.matchMessages = messages
            }).store(in: &cancellables)
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
    
    func getTempMessages(uid: String) {
        if let msgs = MessageService_CoreData.shared.getAllMessages(fromUserWith: uid) {
            self.tempMessages = msgs
        } else {
            self.tempMessages = []
        }
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
        MessageService_Firebase.shared.openMessage(message: message)
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
            
            MessageService_Firebase.shared.sendMessage(message: messageText, toID: toUID)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
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
                    self?.getTempMessages(uid: toUID)
                }
                .store(in: &cancellables)
        }
    }
}
