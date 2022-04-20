//
//  MessageService_CoreData.swift
//  Gala
//
//  Created by Vaughn on 2022-04-20.
//

import Foundation
import CoreData

protocol MessageService_CoreDataProtocol {
    func addMessage(msg: Message) -> Void
    func getMessage(with docID: String) -> Message
    func getAllMessages(fromUserWith uid: String) -> [Message]
    func readMessage(with docID: String) -> Void
    func deleteMessage(with docID: String) -> Void
}

class MessageService_CoreData: MessageService_CoreDataProtocol {
    
    static let shared = MessageService_CoreData()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "MessageCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("MessageService_CoreData: Failed to load container")
                print("MessageService_CoreData-err: \(e)")
            }
        }
    }
    
    func addMessage(msg: Message) {
        
    }
    
    func getMessage(with docID: String) -> Message {
        return Message(message: "", toID: "", fromID: "", time: Date(), docID: "")
    }
    
    func getAllMessages(fromUserWith uid: String) -> [Message] {
        return [Message]()
    }
    
    func readMessage(with docID: String) {
        
    }
    
    func deleteMessage(with docID: String) {
        
    }
}
