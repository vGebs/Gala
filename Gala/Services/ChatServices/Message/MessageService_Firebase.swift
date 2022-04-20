//
//  MessageService_Firebase.swift
//  Gala
//
//  Created by Vaughn on 2022-04-20.
//

import FirebaseFirestore
import Combine

protocol MessageServiceProtocol {
    associatedtype void
    associatedtype messages
    
    func sendMessage(message: String, toID: String) -> void
    func openMessage(message: Message) -> void
    func observeChatsFromMe(completion: @escaping ([Message], DocumentChangeType) -> Void)
    func observeChatsToMe(completion: @escaping ([Message], DocumentChangeType) -> Void)
}

class MessageService_Firebase: MessageServiceProtocol {
    
    private let db = Firestore.firestore()
    private var cancellables: [AnyCancellable] = []

    static let shared = MessageService_Firebase()
    private init() {}
    
    typealias void = AnyPublisher<Void, Error>
    typealias messages = AnyPublisher<[Message], Error>
    
    func sendMessage(message: String, toID: String) -> void {
        return Future<Void, Error> { [weak self] promise in
            self!.db.collection("Messages")
                .addDocument(data: [
                    "message": message,
                    "toID": toID,
                    "fromID": AuthService.shared.currentUser!.uid,
                    "timestamp": Date()
                ]){ err in
                    if let err = err {
                        print("ChatService: Failed to send message to id: \(toID)")
                        print("ChatService-Error: \(err.localizedDescription)")
                        promise(.failure(err))
                    } else {
                        print("ChatService: Successfully send message to user with id: \(toID)")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func openMessage(message: Message) -> void {
        //we want to open the last message only since we are only checking the value of the most recent message
        return Future<Void, Error> { [weak self] promise in
            self?.db.collection("Messages").document(message.docID)
                .updateData(["openedDate": Date()]) { err in
                    if let e = err {
                        print("ChatService: Failed to update document")
                        print("ChatService-err: \(e)")
                        promise(.failure(e))
                    } else {
                        print("ChatService: Successfully updated document")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
}

extension MessageService_Firebase {
    func observeChatsFromMe(completion: @escaping ([Message], DocumentChangeType) -> Void) {
        db.collection("Messages")
            .whereField("fromID", isEqualTo: AuthService.shared.currentUser!.uid)
            .order(by: "timestamp")
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("ChatsDataStore: Failed to observe chats from me")
                    print("ChatsDataStore-err: \(error!)")
                    return
                }
                
                var final: [Message] = []
                var documentChangeType: DocumentChangeType = .added
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    
                    let fromID = data["fromID"] as? String ?? ""
                    let toID = data["toID"] as? String ?? ""
                    let message = data["message"] as? String ?? ""
                    let opened = data["openedDate"] as? Timestamp
                    let timestamp = data["timestamp"] as? Timestamp
                    
                    if let date = timestamp?.dateValue() {
                        if let o = opened {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: change.document.documentID)
                            
                            final.append(message)
                        } else {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: nil, docID: change.document.documentID)
                            
                            final.append(message)
                        }
                    }
                    
                    if change.type == .modified {
                        documentChangeType = .modified
                        
                    } else if change.type == .removed {
                        documentChangeType = .removed
                    }
                })
                completion(final, documentChangeType)
            }
    }
    
    func observeChatsToMe(completion: @escaping ([Message], DocumentChangeType) -> Void) {
        db.collection("Messages")
            .whereField("toID", isEqualTo: AuthService.shared.currentUser!.uid)
            .order(by: "timestamp")
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("ChatsDataStore: Failed to observe chats from me")
                    print("ChatsDataStore-err: \(error!)")
                    return
                }
                
                var final: [Message] = []
                var documentChangeType: DocumentChangeType = .added
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    
                    let fromID = data["fromID"] as? String ?? ""
                    let toID = data["toID"] as? String ?? ""
                    let message = data["message"] as? String ?? ""
                    let opened = data["openedDate"] as? Timestamp
                    let timestamp = data["timestamp"] as? Timestamp
                    
                    if let date = timestamp?.dateValue() {
                        if let o = opened {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: change.document.documentID)
                            
                            final.append(message)
                        } else {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: nil, docID: change.document.documentID)
                            
                            final.append(message)
                        }
                    }
                    
                    if change.type == .modified {
                        documentChangeType = .modified
                        
                    } else if change.type == .removed {
                        documentChangeType = .removed
                    }
                })
                completion(final, documentChangeType)
            }
    }
}

// MARK: - Helpers
extension MessageService_Firebase {
    private func cmp(_ message1: Date, _ message2: Date) -> Bool {
        if message1 < message2 {
            return true
        } else {
            return false
        }
    }
}
