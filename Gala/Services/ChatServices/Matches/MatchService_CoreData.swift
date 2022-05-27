//
//  MatchService_CoreData.swift
//  Gala
//
//  Created by Vaughn on 2022-04-21.
//

import Foundation
import CoreData

protocol MatchService_CoreDataProtocol {
    func addMatch(match: Match)
    func getMatches(for uid: String) -> [Match]?
    func getMostRecentMatchDate() -> Date?
    func deleteMatch(for uid: String)
}

class MatchService_CoreData: MatchService_CoreDataProtocol {
    
    static let shared = MatchService_CoreData()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "MatchCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("MatchService_CoreData: Failed to load container")
                print("MatchService_CoreData-err: \(e)")
            }
        }
    }
    
    func addMatch(match: Match) {
        //we want to only add the match if the match doesnt already exist
        if !matchExists(for: match.matchedUID) {
            do {
                let matchCD = MatchCD(context: persistentContainer.viewContext)
                
                bundleMatchCD(match: match, cd: matchCD)
                
                try persistentContainer.viewContext.save()
                print("MatchService_CoreData: Successfully added new match")
                return
            } catch {
                //we should probably do something here such as retry
                print("MatchService_CoreData-err: Failed to add new match: \(error)")
                return
            }
        } else {
            print("MatchService_CoreData: tried to re-add match")
        }
    }
    
    func getMatches(for currentUID: String) -> [Match]? {
        if let matches = getAllMatchesCD(for: currentUID) {
            var final: [Match] = []
            for match in matches {
                final.append(bundleMatch(cd: match))
            }
            print("MatchService_CoreData: Got matches with uid -> \(currentUID)")
            return final
        } else {
            print("MatchService_CoreData: No matches with uid -> \(currentUID)")
            return nil
        }
    }
    
    func getMostRecentMatchDate() -> Date? {
        let fetchRequest: NSFetchRequest<MatchCD> = MatchCD.fetchRequest()
        let predicate = NSPredicate(format: "myUID == %@", AuthService.shared.currentUser!.uid)
        fetchRequest.predicate = predicate
        
        do {
            let matches = try persistentContainer.viewContext.fetch(fetchRequest)
            if matches.count > 0 {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let timestamp: Date = formatter.date(from: "1997/06/12 07:30")!
                
                var newestMatchDate: Date = timestamp
                
                for match in matches {
                    if match.matchedDate! > timestamp {
                        newestMatchDate = match.matchedDate!
                    }
                }
                
                return newestMatchDate
            }
            
            return nil
            
        } catch {
            print("MatchService_CoreData: Failed getting getting all matches")
            return nil
        }
    }
    
    func deleteMatch(for uid: String) {
        if let match = getMatchCD(with: uid) {
            
            persistentContainer.viewContext.delete(match)

            do {
                try persistentContainer.viewContext.save()
                print("MatchService_CoreData: Deleted match with uid -> \(uid)")
                return
            } catch {
                print("MatchService_CoreData: Could not delete match with uid -> \(uid)")
                return
            }
        }
    }
    
    func clear() {
        let matches = getAllMatches()
        
        for match in matches {
            self.deleteMatch(for: match.matchedUID)
        }
    }
}

extension MatchService_CoreData {
    
    private func getAllMatches() -> [Match] {
        let fetchRequest: NSFetchRequest<MatchCD> = MatchCD.fetchRequest()
        
        do {
            let matchesCD = try persistentContainer.viewContext.fetch(fetchRequest)
            
            var matches: [Match] = []
            
            for match in matchesCD {
                matches.append(bundleMatch(cd: match))
            }
            
            return matches
        } catch {
            
            print("MatchService_CoreData: Failed to fetch all stories")
            print("MatchService_CoreData: Failed to save context")
            
            return []
        }
    }
    
    func getMatch(with uid: String) -> Match? {
        if let match = getMatchCD(with: uid) {
            return bundleMatch(cd: match)
        } else {
            return nil
        }
    }
}

extension MatchService_CoreData {
    private func matchExists(for uid: String) -> Bool {
        let fetchRequest: NSFetchRequest<MatchCD> = MatchCD.fetchRequest()
        let predicate = NSPredicate(format: "matchedUID == %@", uid)
        fetchRequest.predicate = predicate
        
        do {
            let matches = try persistentContainer.viewContext.fetch(fetchRequest)
            if matches.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("MatchService_CoreData: Could not find match w uid: \(uid)")
            return false
        }
    }
    
    private func bundleMatch(cd: MatchCD) -> Match {
        return Match(matchedUID: cd.matchedUID!, timeMatched: cd.matchedDate!, docID: cd.docID!)
    }
    
    private func bundleMatchCD(match: Match, cd: MatchCD) {
        cd.matchedUID = match.matchedUID
        cd.matchedDate = match.timeMatched
        cd.myUID = AuthService.shared.currentUser!.uid
        cd.docID = match.docID
    }
    
    private func getAllMatchesCD(for currentUID: String) -> [MatchCD]? {
        let fetchRequest: NSFetchRequest<MatchCD> = MatchCD.fetchRequest()
        let fromIDPredicate = NSPredicate(format: "myUID == %@", currentUID)

        let sectionSortDescriptor = NSSortDescriptor(key: "matchedDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        
        fetchRequest.predicate = fromIDPredicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let matches = try persistentContainer.viewContext.fetch(fetchRequest)
            if matches.count > 0 {
                return matches
            } else {
                return nil
            }
        } catch {
            print("MatchService_CoreData: Could not find match w uid: \(currentUID)")
            return nil
        }
    }
    
    private func getMatchCD(with uid: String) -> MatchCD? {
        let fetchRequest: NSFetchRequest<MatchCD> = MatchCD.fetchRequest()
        let predicate = NSPredicate(format: "matchedUID == %@", uid)
        fetchRequest.predicate = predicate
        
        do {
            let messages = try persistentContainer.viewContext.fetch(fetchRequest)
            if messages.count > 0 {
                return messages[0]
            } else {
                return nil
            }
        } catch {
            print("MatchService_CoreData: Could not find match w matchedUID: \(uid)")
            return nil
        }
    }
}
