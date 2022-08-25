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
    func observeChatsFromMe(olderThan date: Date, completion: @escaping ([Message]) -> Void)
    func observeChatsToMe(olderThan date: Date, completion: @escaping ([Message]) -> Void)
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
                    "fromName": UserCoreService.shared.currentUserCore!.userBasic.name,
                    "timestamp": Date()
                ]){ err in
                    if let err = err {
                        print("MessageService_Firebase: Failed to send message to id: \(toID)")
                        print("MessageService_Firebase-Error: \(err.localizedDescription)")
                        promise(.failure(err))
                    } else {
                        print("MessageService_Firebase: Successfully send message to user with id: \(toID)")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    func deleteMessage(message: Message) -> void {
        return Future<Void, Error> { [weak self] promise in
            self?.db.collection("Messages").document(message.docID).delete() { err in
                if let e = err {
                    print("MessageService_Firebase: Failed to delete Message")
                    print("MessageService_Firebase-err: \(e)")
                    promise(.failure(e))
                }
                
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    func openMessage(message: Message) -> void {
        //we want to open the last message only since we are only checking the value of the most recent message
        return Future<Void, Error> { [weak self] promise in
            self?.db.collection("Messages").document(message.docID)
                .updateData(["openedDate": Date()]) { err in
                    if let e = err {
                        print("MessageService_Firebase: Failed to update document")
                        print("MessageService_Firebase-err: \(e)")
                        promise(.failure(e))
                    } else {
                        print("MessageService_Firebase: Successfully updated document")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
}

extension MessageService_Firebase {
    func observeChatsFromMe(olderThan date: Date, completion: @escaping ([Message]) -> Void) {
        db.collection("Messages")
            .whereField("fromID", isEqualTo: AuthService.shared.currentUser!.uid)
            .whereField("timestamp", isGreaterThanOrEqualTo: date)
            .order(by: "timestamp")
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("MessageService_Firebase: Failed to observe chats from me")
                    print("MessageService_Firebase-err: \(error!)")
                    return
                }
                
                var final: [Message] = []
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    
                    let fromID = data["fromID"] as? String ?? ""
                    let toID = data["toID"] as? String ?? ""
                    let message = data["message"] as? String ?? ""
                    let opened = data["openedDate"] as? Timestamp
                    let timestamp = data["timestamp"] as? Timestamp
                    
                    if let date = timestamp?.dateValue() {
                        if let o = opened {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: change.document.documentID, changeType: change.type)
                            
                            final.append(message)
                        } else {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, docID: change.document.documentID, changeType: change.type)
                            
                            final.append(message)
                        }
                    }
                })
                completion(final)
            }
    }
    
    func observeChatsToMe(olderThan date: Date, completion: @escaping ([Message]) -> Void) {
        db.collection("Messages")
            .whereField("toID", isEqualTo: AuthService.shared.currentUser!.uid)
            .whereField("timestamp", isGreaterThanOrEqualTo: date)
            .order(by: "timestamp")
            .addSnapshotListener { documentSnapshot, error in
                guard let  _ = documentSnapshot?.documents else {
                    print("MessageService_Firebase: Failed to observe chats from me")
                    print("MessageService_Firebase-err: \(error!)")
                    return
                }
                
                var final: [Message] = []
                
                documentSnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    
                    let fromID = data["fromID"] as? String ?? ""
                    let toID = data["toID"] as? String ?? ""
                    let message = data["message"] as? String ?? ""
                    let opened = data["openedDate"] as? Timestamp
                    let timestamp = data["timestamp"] as? Timestamp
                    
                    if let date = timestamp?.dateValue() {
                        if let o = opened {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: change.document.documentID, changeType: change.type)
                            
                            final.append(message)
                        } else {
                            let message = Message(message: message, toID: toID, fromID: fromID, time: date, docID: change.document.documentID, changeType: change.type)
                            
                            final.append(message)
                        }
                    }
                })
                completion(final)
            }
    }
    
    func observeMessage(for docID: String, completion: @escaping (Message?) -> Void) {
        db.collection("Messages").document(docID).addSnapshotListener { documentSnapshot, error in
            guard let doc = documentSnapshot else {
                print("MessageService_Firebase: Failed to observe chats from me")
                print("MessageService_Firebase-err: \(error!)")
                return
            }
            
            if doc.exists {
                var message: Message?
                if let data = doc.data() {
                    let fromID = data["fromID"] as? String ?? ""
                    let toID = data["toID"] as? String ?? ""
                    let messageText = data["message"] as? String ?? ""
                    let opened = data["openedDate"] as? Timestamp
                    let timestamp = data["timestamp"] as? Timestamp
                    
                    if let date = timestamp?.dateValue() {
                        if let o = opened {
                            message = Message(message: messageText, toID: toID, fromID: fromID, time: date, openedDate: o.dateValue(), docID: doc.documentID)
                            
                        } else {
                            message = Message(message: messageText, toID: toID, fromID: fromID, time: date, docID: doc.documentID)
                            
                        }
                    }
                }
                
                completion(message)
            } else {
                completion(nil)
            }
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
