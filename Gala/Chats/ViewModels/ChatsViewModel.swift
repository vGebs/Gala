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
    
    private var subs: [AnyCancellable] = []
        
    @Published private(set) var matches: [MatchedUserCore] = []
    @Published var snaps: OrderedDictionary<String, [Snap]> = [:]
    @Published var matchMessages: OrderedDictionary<String, [Message]> = [:] //Key = uid, value = [message]
    
    @Published var tempMessages: [Message] = []
    
    @Published var showChat = false
    @Published var userChat: UserChat = UserChat(name: "", uid: "", location: Coordinate(lat: 91, lng: 181), bday: Date(), profileImg: nil)
    @Published var timeMatched: Date? = nil
    
    @Published var tempSnap: Snap?
    @Published var tempCounter = 0
    @Published private var toBeDeleted: [Snap] = []
    @Published private var toBeOpened: [Snap] = []

    @Published var messageText = ""
    
    @Published var lastMatchUpdate: Date?
    
    deinit {
        print("ChatsViewModel: Deinitializing")
    }
    
    init() {
        DataStore.shared.chats.$matches
            .sink(receiveValue: { [weak self] matches in
                self?.matches = matches
            }).store(in: &subs)

        DataStore.shared.chats.$snaps
            .sink(receiveValue: { [weak self] snaps in
                self?.snaps = snaps
            }).store(in: &subs)
            
        DataStore.shared.chats.$messages
            .sink(receiveValue: { [weak self] messages in
                self?.matchMessages = messages
            }).store(in: &subs)
    }
    
    func getTempMessages(uid: String) {
        if let msgs = MessageService_CoreData.shared.getAllMessages(fromUserWith: uid) {
            self.tempMessages = msgs
        } else {
            self.tempMessages = []
        }
    }
    
    func getSnap(for uid: String) {
        //we need to get the first snap in the array for
        let snaps = getUnopenedSnaps(from: uid)
        
        if tempCounter < snaps.count {
            if let snap = SnapService_CoreData.shared.getSnap(with: snaps[tempCounter].docID) {
                self.tempSnap = snap
                
                let mostRecent: Snap? = getMostRecentSnap(for: uid)
                
                if let mostRecent = mostRecent {
                    if snap.docID == mostRecent.docID {
                        self.toBeOpened.append(snap)
                    } else if snap.snapID_timestamp < mostRecent.snapID_timestamp {
                        self.toBeDeleted.append(snap)
                    }
                } else {
                    self.toBeOpened.append(snap)
                }
                
                self.tempCounter += 1
            }
        }
    }
    
    func clearSnaps(for uid: String) {
        if let _ = self.snaps[uid] {
                    
            //we need to get the most recent snap from that user
            
            let mostRecentSnap: Snap? = getMostRecentSnap(for: uid)
            
            for snap in toBeDeleted {
                if let mostRecentSnap = mostRecentSnap {
                    if snap.snapID_timestamp != mostRecentSnap.snapID_timestamp {
                        deleteSnap(snap: snap)
                    }
                }
            }
            
            for snap in toBeOpened {
                openSnap(snap)
            }
            
            tempCounter = 0
            tempSnap = nil
        }
    }
    
    func getUnopenedSnaps(from uid: String) -> [Snap] {
        var final: [Snap] = []
        if let snaps = snaps[uid] {
            for snap in snaps {
                if snap.openedDate == nil && snap.fromID != AuthService.shared.currentUser!.uid {
                    final.append(snap)
                }
            }
        }
        
        return final.sorted { snap1, snap2 in
            snap1.snapID_timestamp < snap2.snapID_timestamp
        }        
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
            .store(in: &subs)
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
                    self?.getTempMessages(uid: toUID)
                }
                .store(in: &subs)
            
            messageText = ""
        }
    }
}

extension ChatsViewModel {
    private func openSnap(_ snap: Snap) {
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
            .store(in: &subs)
    }
    
    private func deleteSnap(snap: Snap) {
        SnapService.shared.deleteSnap(snap: snap)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ChatsViewModel: Failed to delete snap with docID -> \(snap.docID)")
                    print("ChatsViewModel-err: \(e)")
                case .finished:
                    print("ChatsViewModel: Successfully deleted snap with docID -> \(snap.docID)")
                }
            } receiveValue: { _ in }
            .store(in: &subs)
    }
}



extension ChatsViewModel {
    enum ConvoPreviewType {
        case unOpenedSnapToMe //1
        case unOpenedMessageToMe//2
        case unOpenedSnapFromMe//3
        case openedSnapFromMe//4
        case openedSnapToMe//5
        case unOpenedMessageFromMe//6
        case openedMessageFromMe//7
        case openedMessageToMe//8
        
        case newMatch
    }

    enum ConvoPressType {
        case openSnap
        case viewChat
    }
    
    private func bundleUserChat(ucMatch: MatchedUserCore) {
        self.userChat = UserChat(
            name: ucMatch.uc.userBasic.name,
            uid: ucMatch.uc.userBasic.uid,
            location: ucMatch.uc.searchRadiusComponents.coordinate,
            bday: ucMatch.uc.userBasic.birthdate,
            profileImg: ucMatch.profileImg
        )
    }
    
    func convoPressed(for ucMatch: MatchedUserCore) -> ConvoPressType {
        
        let uid = ucMatch.uc.userBasic.uid
        
        //We've got both snaps and messages
        if let snaps = snaps[uid], let _ = matchMessages[uid] {
            //if there is unopenedSnaps, open them
            print("we have both snaps and messages")
            if snaps[snaps.count - 1].openedDate == nil && snaps[snaps.count - 1].toID == AuthService.shared.currentUser!.uid{
                
                bundleUserChat(ucMatch: ucMatch)
                getSnap(for: uid)
                return ConvoPressType.openSnap
                
            } else {
                let mostRecentMessage = getMostRecentMessage(for: uid)
                
                if let mostRecentMessage = mostRecentMessage {
                    if mostRecentMessage.openedDate == nil && mostRecentMessage.toID == AuthService.shared.currentUser!.uid{
                        //we have an unopened message to us, we need to open it
                        bundleUserChat(ucMatch: ucMatch)
                        openMessage(message: mostRecentMessage)
                        getTempMessages(uid: uid)
                        return ConvoPressType.viewChat
                    } else {
                        bundleUserChat(ucMatch: ucMatch)
                        getTempMessages(uid: uid)
                        return ConvoPressType.viewChat
                    }
                } else {
                    //All snaps are opened and there are no messages, so we just set
                    bundleUserChat(ucMatch: ucMatch)
                    getTempMessages(uid: uid)
                    return ConvoPressType.viewChat
                }
            }
        } else if let snaps = snaps[uid] {
            if snaps[snaps.count - 1].openedDate == nil && snaps[snaps.count - 1].toID == AuthService.shared.currentUser!.uid{
                bundleUserChat(ucMatch: ucMatch)
                getSnap(for: uid)
                
                return ConvoPressType.openSnap
                
            } else {
                //All snaps are opened and there are no messages, so we just set
                bundleUserChat(ucMatch: ucMatch)
                getTempMessages(uid: uid)
                return ConvoPressType.viewChat
            }
        } else if let _ = matchMessages[uid] {
            //if the snaps are opened, check to see if the messages are opened
            let mostRecentMessage = getMostRecentMessage(for: uid)
            
            if let mostRecentMessage = mostRecentMessage {
                if mostRecentMessage.openedDate == nil && mostRecentMessage.toID == AuthService.shared.currentUser!.uid{
                    //we have an unopened message to us, we need to open it
                    bundleUserChat(ucMatch: ucMatch)
                    openMessage(message: mostRecentMessage)
                    getTempMessages(uid: uid)
                    return ConvoPressType.viewChat
                } else {
                    bundleUserChat(ucMatch: ucMatch)
                    getTempMessages(uid: uid)
                    return ConvoPressType.viewChat
                }
            } else {
                //All snaps are opened and there are no messages, so we just set
                bundleUserChat(ucMatch: ucMatch)
                getTempMessages(uid: uid)
                return ConvoPressType.viewChat
            }
        } else {
            //we got nothing, so set the temp messages to nil
            tempMessages = []
        }
        
        return ConvoPressType.viewChat
    }
        
    func convoReceipt(for uid: String) -> ConvoPreviewType {
        if isThereUnOpenedSnapsToMe(from: uid) {
            //show unopened snap to me view (1)
            return ConvoPreviewType.unOpenedSnapToMe
        }
        
        if !theLastMessageToMeWasOpened(from: uid) && !isThereUnOpenedSnapsToMe(from: uid) {
            //show unopened message to me view (2)
            return ConvoPreviewType.unOpenedMessageToMe
        }
        
        if !isThereUnOpenedSnapsToMe(from: uid) && theLastMessageToMeWasOpened(from: uid) {
            //compare the most recent chat or snap
            let mostRecentSnap: Snap? = getMostRecentSnap(for: uid)
            let mostRecentMessage: Message? = getMostRecentMessage(for: uid)
            
            //case 1: there is both a snap and message
            if let mostRecentSnap = mostRecentSnap, let mostRecentMessage = mostRecentMessage {
                //if there is both a snap and message, we compare the sent dates
                
                if let mostRecentOpenedSnapDate = mostRecentSnap.openedDate,
                    let mostRecentOpenedMessageDate = mostRecentMessage.openedDate {
                    if mostRecentOpenedSnapDate > mostRecentOpenedMessageDate {
                        if let receipt = openClose_toFrom(
                            openedDate: mostRecentSnap.openedDate,
                            toID: mostRecentSnap.toID,
                            fromID: mostRecentSnap.fromID
                        ) {
                            switch receipt {
                            case .unOpenedFromMe:
                                return ConvoPreviewType.unOpenedSnapFromMe
                            case .openedFromMe:
                                return ConvoPreviewType.openedSnapFromMe
                            case .openedToMe:
                                return ConvoPreviewType.openedSnapToMe
                            }
                        }
                    } else if mostRecentOpenedSnapDate < mostRecentOpenedMessageDate {
                        if let receipt = openClose_toFrom(
                            openedDate: mostRecentMessage.openedDate,
                            toID: mostRecentMessage.toID,
                            fromID: mostRecentMessage.fromID
                        ) {
                            switch receipt {
                            case .unOpenedFromMe:
                                return ConvoPreviewType.unOpenedMessageFromMe
                            case .openedFromMe:
                                return ConvoPreviewType.openedMessageFromMe
                            case .openedToMe:
                                return ConvoPreviewType.openedMessageToMe
                            }
                        }
                    }
                } else if mostRecentSnap.snapID_timestamp > mostRecentMessage.time {
                    //Most recent is a snap
                    
                    if let receipt = openClose_toFrom(
                        openedDate: mostRecentSnap.openedDate,
                        toID: mostRecentSnap.toID,
                        fromID: mostRecentSnap.fromID
                    ) {
                        switch receipt {
                        case .unOpenedFromMe:
                            return ConvoPreviewType.unOpenedSnapFromMe
                        case .openedFromMe:
                            return ConvoPreviewType.openedSnapFromMe
                        case .openedToMe:
                            return ConvoPreviewType.openedSnapToMe
                        }
                    }
                    
                } else if mostRecentSnap.snapID_timestamp < mostRecentMessage.time {
                    //Most recent is a message
                    
                    if let receipt = openClose_toFrom(
                        openedDate: mostRecentMessage.openedDate,
                        toID: mostRecentMessage.toID,
                        fromID: mostRecentMessage.fromID
                    ) {
                        switch receipt {
                        case .unOpenedFromMe:
                            return ConvoPreviewType.unOpenedMessageFromMe
                        case .openedFromMe:
                            return ConvoPreviewType.openedMessageFromMe
                        case .openedToMe:
                            return ConvoPreviewType.openedMessageToMe
                        }
                    }
                }
            } else if let mostRecentSnap = mostRecentSnap { //case 2: there is just a snap
                //Most recent is a snap
                
                if let receipt = openClose_toFrom(
                    openedDate: mostRecentSnap.openedDate,
                    toID: mostRecentSnap.toID,
                    fromID: mostRecentSnap.fromID
                ) {
                    switch receipt {
                    case .unOpenedFromMe:
                        return ConvoPreviewType.unOpenedSnapFromMe
                    case .openedFromMe:
                        return ConvoPreviewType.openedSnapFromMe
                    case .openedToMe:
                        return ConvoPreviewType.openedSnapToMe
                    }
                }
                
            } else if let mostRecentMessage = mostRecentMessage { //case 3: there is just a message
                //most recent is a message
                
                if let receipt = openClose_toFrom(
                    openedDate: mostRecentMessage.openedDate,
                    toID: mostRecentMessage.toID,
                    fromID: mostRecentMessage.fromID
                ) {
                    switch receipt {
                    case .unOpenedFromMe:
                        return ConvoPreviewType.unOpenedMessageFromMe
                    case .openedFromMe:
                        return ConvoPreviewType.openedMessageFromMe
                    case .openedToMe:
                        return ConvoPreviewType.openedMessageToMe
                    }
                }
            }
        }
        
        return ConvoPreviewType.newMatch
    }
    
    enum ShouldShowChatPreview {
        case doNotShow
        case showNewMessage
        case showOldMessage
    }
    
    func shouldShowChatPreview(ucMatch: MatchedUserCore) -> ShouldShowChatPreview {
        let uid = ucMatch.uc.userBasic.uid
        let currentUID = AuthService.shared.currentUser!.uid
        
        if let snaps = snaps[uid] {
            if snaps[snaps.count - 1].openedDate == nil && snaps[snaps.count - 1].toID == currentUID {
                //we have a new snap to us
                if let msgs = matchMessages[uid] {
                    if msgs[msgs.count - 1].openedDate == nil && msgs[msgs.count - 1].toID == currentUID {
                        //we have a new message as well
                        return ShouldShowChatPreview.showNewMessage
                    } else {
                        return ShouldShowChatPreview.showOldMessage
                    }
                } else {
                    return ShouldShowChatPreview.showOldMessage
                }
            }
        }
        
        return ShouldShowChatPreview.doNotShow
    }
    
    func secondaryConvoPreviewButtonPressed(ucMatch: MatchedUserCore) {
        let uid = ucMatch.uc.userBasic.uid
        let currentUID = AuthService.shared.currentUser!.uid
        
        if let _ = matchMessages[uid] {
            let mostRecentMessage = getMostRecentMessage(for: uid)!
            
            if mostRecentMessage.openedDate == nil && mostRecentMessage.toID == currentUID {
                bundleUserChat(ucMatch: ucMatch)
                openMessage(message: mostRecentMessage)
                getTempMessages(uid: uid)
            } else {
                bundleUserChat(ucMatch: ucMatch)
                getTempMessages(uid: uid)
            }
        } else {
            bundleUserChat(ucMatch: ucMatch)
        }
    }
    
    private enum OpenClose_ToFrom {
        case unOpenedFromMe
        case openedFromMe
        case openedToMe
    }
    
    private func openClose_toFrom(openedDate: Date?, toID: String, fromID: String) -> OpenClose_ToFrom? {
        if openedDate == nil {
            if fromID == AuthService.shared.currentUser!.uid {
                return OpenClose_ToFrom.unOpenedFromMe
            }
        } else {
            if fromID == AuthService.shared.currentUser!.uid {
                return OpenClose_ToFrom.openedFromMe
            } else if toID == AuthService.shared.currentUser!.uid {
                return OpenClose_ToFrom.openedToMe
            }
        }
        return nil
    }
    
    private func isThereUnOpenedSnapsToMe(from uid: String) -> Bool {
        
        if let snaps = self.snaps[uid] {
            return snaps[snaps.count - 1].openedDate == nil && snaps[snaps.count - 1].toID == AuthService.shared.currentUser!.uid
        }
        
        return false
    }
    
    private func theLastMessageToMeWasOpened(from uid: String) -> Bool {
        
        if let msgs = self.matchMessages[uid] {
            for msg in msgs.reversed() {
                if msg.toID == AuthService.shared.currentUser!.uid {
                    if msg.openedDate != nil {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    private func getMostRecentSnap(for uid: String) -> Snap? {
        
        if let snaps = self.snaps[uid] {
            return snaps[snaps.count - 1]
        }
        
        return nil
    }
    
    private func getMostRecentMessage(for uid: String) -> Message? {
        
        if let msgs = self.matchMessages[uid] {
            return msgs[msgs.count - 1]
        }
        
        return nil
    }
}
