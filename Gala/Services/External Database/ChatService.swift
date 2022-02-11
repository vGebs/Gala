//
//  ChatService.swift
//  Gala
//
//  Created by Vaughn on 2022-02-10.
//

import FirebaseFirestore
import Combine
import UIKit

class ChatService {
    static let shared = ChatService()
    
    private let db = Firestore.firestore()
    private var cancellables: [AnyCancellable] = []
    
    private init() {}
    
    func sendMessage(message: String, toID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection("Messages")
                .addDocument(data: [
                    "message": message,
                    "toID": toID,
                    "fromID": AuthService.shared.currentUser!.uid,
                    "timestamp": Date(),
                    "opened": false
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
    
    func getMessages(forID: String) -> AnyPublisher<[Message], Error> {
        return Future<[Message], Error> { promise in
            Publishers.Zip(
                self.getMessagesToMe(fromUserID: forID),
                self.getMessagesFromMe(toUserID: forID)
            ).sink{ completion in
                switch completion {
                case .failure(let e):
                    print("ChatService: Failed to fetch messages")
                    print("ChatService-err: \(e)")
                    promise(.failure(e))
                case .finished:
                    print("ChatService: Successfully fetched messages")
                }
            } receiveValue: { toMe, fromMe in
                
                if toMe.count == 0 {
                    promise(.success(fromMe))
                } else if fromMe.count == 0 {
                    promise(.success(toMe))
                } else {
                    var z = [Message]()
                    var i = 0, j = 0
                    while i < toMe.count || j < fromMe.count {
                        if j == fromMe.count || self.cmp(toMe[i].time, fromMe[j].time) {
                            z.append(toMe[i])
                            i += 1
                        } else {
                            z.append(fromMe[j])
                            j += 1
                        }
                    }
                    promise(.success(z))
                }
            }.store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func cmp(_ message1: Date, _ message2: Date) -> Bool {
        if message1 < message2 {
            return true
        } else {
            return false
        }
    }
    
    private func getMessagesToMe(fromUserID: String) -> AnyPublisher<[Message], Error> {
        return Future<[Message], Error> { promise in
            self.db.collection("Messages")
                .whereField("fromID", isEqualTo: fromUserID)
                .whereField("toID", isEqualTo: AuthService.shared.currentUser!.uid)
                .order(by: "timestamp")
                .getDocuments { snapshot, error in
                    if let e = error {
                        print("ChatService: Failed to fetch messages from me to \(fromUserID)")
                        promise(.failure(e))
                    }
                    
                    var final: [Message] = []
                    
                    if let docs = snapshot?.documents {
                        for doc in docs {
                            let message = doc.data()["message"] as? String ?? ""
                            let toID = doc.data()["fromID"] as? String ?? ""
                            let fromID = doc.data()["toID"] as? String ?? ""
                            let opened = doc.data()["opened"] as? Bool ?? false
                            
                            let date = doc.data()["timestamp"] as? Timestamp
                            if let dateFinal = date?.dateValue() {
                                let newMessage = Message(message: message, toID: toID, fromID: fromID, time: dateFinal, opened: opened)
                                final.append(newMessage)
                            }
                        }
                    }
                    promise(.success(final))
                }
        }.eraseToAnyPublisher()
    }
    
    private func getMessagesFromMe(toUserID: String) -> AnyPublisher<[Message], Error> {
        return Future<[Message], Error> { promise in
            self.db.collection("Messages")
                .whereField("fromID", isEqualTo: AuthService.shared.currentUser!.uid)
                .whereField("toID", isEqualTo: toUserID)
                .order(by: "timestamp")
                .getDocuments { snapshot, error in
                    if let e = error {
                        print("ChatService: Failed to fetch messages from me to \(toUserID)")
                        promise(.failure(e))
                    }
                    
                    var final: [Message] = []
                    
                    if let docs = snapshot?.documents {
                        for doc in docs {
                            let message = doc.data()["message"] as? String ?? ""
                            let toID = doc.data()["fromID"] as? String ?? ""
                            let fromID = doc.data()["toID"] as? String ?? ""
                            let opened = doc.data()["opened"] as? Bool ?? false
                            
                            let date = doc.data()["timestamp"] as? Timestamp
                            if let dateFinal = date?.dateValue() {
                                let newMessage = Message(message: message, toID: toID, fromID: fromID, time: dateFinal, opened: opened)
                                final.append(newMessage)
                            }
                        }
                    }
                    promise(.success(final))
                }
        }.eraseToAnyPublisher()
    }
    
    func sendSnap(img: UIImage, toID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}


