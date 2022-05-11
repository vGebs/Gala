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
        //we want to get allMessages where 
        
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
    
    func updateMessage(message: Message) {
        if let msg = getMessageCD(with: message.docID) {
            bundleMessageCD(msg: message, cd: msg)
            
            do {
                try persistentContainer.viewContext.save()
                print("MessageService_CoreData: Updated message with docID -> \(message.docID)")
                return
            } catch {
                print("MessageService_CoreData: Could not update message with docID -> \(message.docID)")
                return
            }
        } else {
            print("MessageService_CoreData: No message to update")
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
    
    func deleteMessages(from uid: String) {
        if let msgs = getAllMessagesCD(for: uid) {
            
            for msg in msgs {
                persistentContainer.viewContext.delete(msg)
            }
            
            do {
                try persistentContainer.viewContext.save()
                print("MessageService_CoreData: Deleted messages with uid -> \(uid)")
                return
            } catch {
                print("MessageService_CoreData: Could not delete message with uid -> \(uid)")
                return
            }
        } else {
            print("MessageService_CoreData: No messages with uid -> \(uid)")
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
    
    func getAllMessages() -> [Message]? {
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        let fromIDPredicate = NSPredicate(format: "toID == %@", AuthService.shared.currentUser!.uid)
        let toIDPredicate = NSPredicate(format: "fromID == %@", AuthService.shared.currentUser!.uid)
        let logicalOrPredicate = NSCompoundPredicate(type: .or, subpredicates: [fromIDPredicate, toIDPredicate])
        
        let sectionSortDescriptor = NSSortDescriptor(key: "sentDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        
        fetchRequest.predicate = logicalOrPredicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let messagesCD = try persistentContainer.viewContext.fetch(fetchRequest)
            
            if messagesCD.count > 0 {
                var final: [Message] = []
                for msg in messagesCD {
                    let message = bundleMessage(cd: msg)
                    final.append(message)
                }
                return final
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
    
    private func getAllMessagesFromMe(forUID: String) -> [MessageCD]? {
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        let fromIDPredicate = NSPredicate(format: "fromID == %@", AuthService.shared.currentUser!.uid)
        let toIDPredicate = NSPredicate(format: "toID == %@", forUID)
        let logicalANDPredicate = NSCompoundPredicate(type: .and, subpredicates: [fromIDPredicate, toIDPredicate])

        let sectionSortDescriptor = NSSortDescriptor(key: "sentDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        
        fetchRequest.predicate = logicalANDPredicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            return messages
        } catch {
            print("MessageService_CoreData: Could not find messages to uid: \(forUID)")
            return nil
        }
    }
    
    private func getAllMessagesToMe(forUID: String) -> [MessageCD]? {
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        let fromIDPredicate = NSPredicate(format: "fromID == %@", forUID)
        let toIDPredicate = NSPredicate(format: "toID == %@", AuthService.shared.currentUser!.uid)
        let logicalANDPredicate = NSCompoundPredicate(type: .and, subpredicates: [fromIDPredicate, toIDPredicate])

        let sectionSortDescriptor = NSSortDescriptor(key: "sentDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        
        fetchRequest.predicate = logicalANDPredicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            return messages
        } catch {
            print("MessageService_CoreData: Could not find messages from uid: \(forUID)")
            return nil
        }
    }
    
    private func getAllMessagesCD(for uid: String) -> [MessageCD]? {
        //we need to get all messages where:
        //  (fromID == uid && toID == me) && (fromID == me && toID == uid)
        
        var final: [MessageCD] = []
        
        if let toMe = getAllMessagesToMe(forUID: uid) {
            final += toMe
        }
        
        if let fromMe = getAllMessagesFromMe(forUID: uid) {
            final += fromMe
        }
        
        if final.count > 0 {
            final.sort { (i1, i2) -> Bool in
                let t1 = i1.sentDate!
                let t2 = i2.sentDate!
                return t1 < t2
            }
            
            return final
        } else {
            return nil
        }
    }
}

extension MessageService_CoreData {
    func deleteAllMessages() {
        //we need to get all messages and then delete them
        if let messages = getAlllMessages() {
            for message in messages {
                deleteMessage(with: message.firestoreDocID!)
            }
        }
    }
    
    func getAlllMessages() -> [MessageCD]? {
        let fetchRequest: NSFetchRequest<MessageCD> = MessageCD.fetchRequest()
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            if messages.count > 0 {
                return messages
            } else {
                return nil
            }
        } catch {
            print("smh bruh")
            return nil
        }
    }
}
