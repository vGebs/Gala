//
//  SnapService_CoreData.swift
//  Gala
//
//  Created by Vaughn on 2022-05-06.
//

import CoreData
import SwiftUI

class SnapService_CoreData {
    static let shared = SnapService_CoreData()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "SnapCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("SnapService_CoreData: Failed to load container")
                print("SnapService_CoreData-err: \(e)")
            }
        }
    }
    
    func addSnap(snap: Snap) {
        if let _ = getSnapCD(with: snap.docID) {
            print("SnapService_CoreData: tried to re-add snap")
        } else {
            do {
                let snapCD = SnapCD(context: persistentContainer.viewContext)
                
                bundleSnapCD(snap: snap, cd: snapCD)
                
                try persistentContainer.viewContext.save()
                print("SnapService_CoreData: Successfully added new snap")
                return
            } catch {
                //we should probably do something here such as retry
                print("SnapService_CoreData-err: Failed to add new snap: \(error)")
                return
            }
        }
    }
    
    func getSnap(with docID: String) -> Snap? {
        if let snap = getSnapCD(with: docID) {
            return bundleSnap(cd: snap)
        } else {
            print("SnapService_CoreData: No snap with docID -> \(docID)")
            return nil
        }
    }
    
    func updateSnap(snap: Snap) {
        if let snapCD = getSnapCD(with: snap.docID) {
            bundleSnapCD(snap: snap, cd: snapCD)
            do {
                try persistentContainer.viewContext.save()
                print("SnapService_CoreData: Successfully updated snap w/ docID -> \(snap.docID)")
                return
            } catch {
                print("SnapService_CoreData: Failed to save context")
                return
            }
        } else {
            print("SnapService_CoreData: No snap to update")
        }
    }
    
    func getAllSnaps(with uid: String) -> [Snap]? {
        if let snaps = getAllSnapsCD(for: uid) {
            var final: [Snap] = []
            for snap in snaps {
                final.append(bundleSnap(cd: snap))
            }
            print("SnapService_CoreData: Got snaps with uid -> \(uid)")
            return final
        } else {
            print("SnapService_CoreData: No messages with uid -> \(uid)")
            return nil
        }
    }
    
    func deleteSnap(docID: String) {
        if let snap = getSnapCD(with: docID) {
            
            persistentContainer.viewContext.delete(snap)

            do {
                try persistentContainer.viewContext.save()
                print("SnapService_CoreData: Deleted snap with docID -> \(docID)")
                return
            } catch {
                print("SnapService_CoreData: Could not delete snap with docID -> \(docID)")
                return
            }
        }
    }
    
    func deleteSnaps(from uid: String) {
        if let snaps = getAllSnapsCD(for: uid) {
            for snap in snaps {
                persistentContainer.viewContext.delete(snap)
            }
            
            do {
                try persistentContainer.viewContext.save()
                print("SnapService_CoreData: Deleted all snaps from user with id -> \(uid)")
                return
            } catch {
                print("SnapService_CoreData: Could not delete snaps from user with uid -> \(uid)")
                return
            }
        }
    }
    
    func clear() {
        print("Clearing")
        let snaps = getAllSnaps()
        print("Snaps count: \(snaps.count)")
        for snap in snaps {
            self.deleteSnap(snapCD: snap)
        }
    }
    
    private func deleteSnap(snapCD: SnapCD) {
        persistentContainer.viewContext.delete(snapCD)
        
        do {
            try persistentContainer.viewContext.save()
            print("SnapService_CoreData: Deleted snap")
            return
        } catch {
            print("SnapService_CoreData: Could not delete snap")
            return
        }
    }
}

extension SnapService_CoreData {
    private func getAllSnaps() -> [SnapCD] {
        let fetchRequest: NSFetchRequest<SnapCD> = SnapCD.fetchRequest()
        
        do {
            let snapsCD = try persistentContainer.viewContext.fetch(fetchRequest)
            
            return snapsCD
        } catch {
            
            print("SnapService_CoreData: Failed to fetch all snaps")
            print("SnapService_CoreData: Failed to save context")
            
            return []
        }
    }
    
    private func getAllSnapsCD(for uid: String) -> [SnapCD]? {
        //we need to get all messages where:
        //  (fromID == uid && toID == me) && (fromID == me && toID == uid)
        
        var final: [SnapCD] = []
        
        if let toMe = getAllSnapsToMe(forUID: uid) {
            final += toMe
        }
        
        if let fromMe = getAllSnapsFromMe(forUID: uid) {
            final += fromMe
        }
        
        if final.count > 0 {
            final.sort { (i1, i2) -> Bool in
                let t1 = i1.snapID_timestamp!
                let t2 = i2.snapID_timestamp!
                return t1 < t2
            }
            
            return final
        } else {
            return nil
        }
    }
    
    private func getAllSnapsToMe(forUID: String) -> [SnapCD]? {
        let fetchRequest: NSFetchRequest<SnapCD> = SnapCD.fetchRequest()
        let fromIDPredicate = NSPredicate(format: "fromID == %@", forUID)
        let toIDPredicate = NSPredicate(format: "toID == %@", AuthService.shared.currentUser!.uid)
        let logicalANDPredicate = NSCompoundPredicate(type: .and, subpredicates: [fromIDPredicate, toIDPredicate])

        let sectionSortDescriptor = NSSortDescriptor(key: "snapID_timestamp", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        
        fetchRequest.predicate = logicalANDPredicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let snaps = try persistentContainer.viewContext.fetch(fetchRequest)
            return snaps
        } catch {
            print("MessageService_CoreData: Could not find messages from uid: \(forUID)")
            return nil
        }
    }
    
    private func getAllSnapsFromMe(forUID: String) -> [SnapCD]? {
        let fetchRequest: NSFetchRequest<SnapCD> = SnapCD.fetchRequest()
        let fromIDPredicate = NSPredicate(format: "fromID == %@", AuthService.shared.currentUser!.uid)
        let toIDPredicate = NSPredicate(format: "toID == %@", forUID)
        let logicalANDPredicate = NSCompoundPredicate(type: .and, subpredicates: [fromIDPredicate, toIDPredicate])

        let sectionSortDescriptor = NSSortDescriptor(key: "snapID_timestamp", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        
        fetchRequest.predicate = logicalANDPredicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let snaps = try persistentContainer.viewContext.fetch(fetchRequest)
            return snaps
        } catch {
            print("MessageService_CoreData: Could not find messages to uid: \(forUID)")
            return nil
        }
    }
}

extension SnapService_CoreData {
    
    func bundleSnap(cd: SnapCD) -> Snap {
        return Snap(
            fromID: cd.fromID!,
            toID: cd.toID!,
            snapID_timestamp: cd.snapID_timestamp!,
            openedDate: cd.openedDate,
            assetData: cd.asset,
            isImage: cd.isImage,
            docID: cd.docID!
        )
    }
    
    func bundleSnapCD(snap: Snap, cd: SnapCD) {
        cd.docID = snap.docID
        cd.fromID = snap.fromID
        cd.toID = snap.toID
        cd.openedDate = snap.openedDate
        cd.isImage = snap.isImage
        cd.snapID_timestamp = snap.snapID_timestamp
        cd.asset = snap.assetData
    }
    
    func getSnapCD(with docID: String) -> SnapCD? {
        let fetchRequest: NSFetchRequest<SnapCD> = SnapCD.fetchRequest()
        let predicate = NSPredicate(format: "docID == %@", docID)
        fetchRequest.predicate = predicate
        
        do {
            let snap = try persistentContainer.viewContext.fetch(fetchRequest)
            if snap.count > 0 {
                return snap[0]
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
