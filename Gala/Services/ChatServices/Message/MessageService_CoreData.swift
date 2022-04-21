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
    func getMessage(with docID: String) -> Message?
    func getAllMessages(fromUserWith uid: String) -> [Message]?
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
        //we want to only add the mesage if the message doesnt already exist
        if !messageExists(docID: msg.docID) {
            do {
                let msgCD = MessageCD(context: persistentContainer.viewContext)
                
                bundleMessageCD(msg: msg, cd: msgCD)
                
                try persistentContainer.viewContext.save()
                print("MessageService_CoreData: Successfully added new message")
                return
            } catch {
                //we should probably do something here such as retry
                print("MessageService_CoreData: Failed to add new message: \(error)")
                return
            }
        } else {
            print("MessageService_CoreData: tried to re-add message")
        }
    }
    
    func getMessage(with docID: String) -> Message? {
        if let msgCD = getMessageCD(with: docID) {
            return bundleMessage(cd: msgCD)
        } else {
            print("MessageService_CoreData: no message with docID -> \(docID)")
            return nil
        }
    }
    
    func getAllMessages(fromUserWith uid: String) -> [Message]? {
        if let msgs = getAllMessagesCD(for: uid) {
            var final: [Message] = []
            for msg in msgs {
                final.append(bundleMessage(cd: msg))
            }
            print("MessageService_CoreData: Got messages with uid -> \(uid)")
            return final
        } else {
            print("MessageService_CoreData: No messages with uid -> \(uid)")
            return nil
        }
    }
    
    func readMessage(with docID: String) {
        if let msg = getMessageCD(with: docID) {
            msg.openedDate = Date()
            
            do {
                try persistentContainer.viewContext.save()
                print("MessageService_CoreData: Read message with docID -> \(docID)")
                return
            } catch {
                print("MessageService_CoreData: Could not read message with docID -> \(docID)")
                return
            }
        }
    }
    
    func deleteMessage(with docID: String) {
        if let msg = getMessageCD(with: docID) {
            
            persistentContainer.viewContext.delete(msg)

            do {
                try persistentContainer.viewContext.save()
                print("MessageService_CoreData: Deleted message with docID -> \(docID)")
                return
            } catch {
                print("MessageService_CoreData: Could not delete message with docID -> \(docID)")
                return
            }
        }
    }
}

extension MessageService_CoreData {
    func getMostRecentMessageDate() -> Date? {
        //we need to fetch all messages and compare sent dates
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            if messages.count > 0 {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let timestamp: Date = formatter.date(from: "1997/06/12 07:30")!
                
                var newestMessageDate: Date = timestamp
                
                for msg in messages {
                    if msg.sentDate! > timestamp {
                        newestMessageDate = msg.sentDate!
                    }
                }
                
                return newestMessageDate
            }
            
            return nil
            
        } catch {
            print("MessageService_CoreData: Failed getting getting all messages")
            return nil
        }
    }
    
    func getMostRecentMessage(for uid: String) -> Message? {
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        let fromIDPredicate = NSPredicate(format: "toID == %@", uid)
        let toIDPredicate = NSPredicate(format: "fromID == %@", uid)
        let logicalOrPredicate = NSCompoundPredicate(type: .or, subpredicates: [fromIDPredicate, toIDPredicate])
        
        fetchRequest.predicate = logicalOrPredicate
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            if messages.count > 0 {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let timestamp: Date = formatter.date(from: "1996/06/12 07:30")!
                
                var newestMessageDate: Date = timestamp
                var newestMessage: Message?
                
                for msg in messages {
                    if msg.sentDate! > newestMessageDate {
                        newestMessageDate = msg.sentDate!
                        
                        newestMessage = Message(
                            message: msg.message!,
                            toID: msg.toID!,
                            fromID: msg.fromID!,
                            time: msg.sentDate!,
                            openedDate: msg.openedDate,
                            docID: msg.firestoreDocID!
                        )
                    }
                }
                
                return newestMessage
            }
            
            return nil
            
        } catch {
            print("MessageService_CoreData: Failed getting getting all messages")
            return nil
        }
    }
}

extension MessageService_CoreData {
    
    private func bundleMessage(cd: MessageCD) -> Message {
        return Message(
            message: cd.message!,
            toID: cd.toID!,
            fromID: cd.fromID!,
            time: cd.sentDate!,
            openedDate: cd.openedDate,
            docID: cd.firestoreDocID!
        )
    }
    
    private func bundleMessageCD(msg: Message, cd: MessageCD) {
        cd.message = msg.message
        cd.fromID = msg.fromID
        cd.toID = msg.toID
        cd.openedDate = msg.openedDate
        cd.sentDate = msg.time
        cd.firestoreDocID = msg.docID
    }
    
    private func messageExists(docID: String) -> Bool {
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        let predicate = NSPredicate(format: "firestoreDocID == %@", docID)
        fetchRequest.predicate = predicate
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            if messages.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("MessageService_CoreData: Could not find message w docID: \(docID)")
            return false
        }
    }
    
    private func getMessageCD(with docID: String) -> MessageCD? {
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        let predicate = NSPredicate(format: "firestoreDocID == %@", docID)
        fetchRequest.predicate = predicate
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            if messages.count > 0 {
                return messages[0]
            } else {
                return nil
            }
        } catch {
            print("MessageService_CoreData: Could not find message w docID: \(docID)")
            return nil
        }
    }
    
    private func getAllMessagesCD(for uid: String) -> [MessageCD]? {
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        let fromIDPredicate = NSPredicate(format: "toID == %@", uid)
        let toIDPredicate = NSPredicate(format: "fromID == %@", uid)
        let logicalOrPredicate = NSCompoundPredicate(type: .or, subpredicates: [fromIDPredicate, toIDPredicate])
        
        fetchRequest.predicate = logicalOrPredicate
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            return messages
        } catch {
            print("MessageService_CoreData: Could not find messages w uid: \(uid)")
            return nil
        }
    }
}
