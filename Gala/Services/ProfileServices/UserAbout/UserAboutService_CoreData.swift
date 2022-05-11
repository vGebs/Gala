//
//  UserAboutPersistence.swift
//  Gala
//
//  Created by Vaughn on 2022-04-04.
//

import Foundation
import CoreData
import Combine


class UserAboutService_CoreData: UserAboutServiceProtocol {
    
    typealias void = Void
    typealias userAbout = UserAbout?
    
    private let persistentContainer: NSPersistentContainer
    
    static let shared = UserAboutService_CoreData()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "UserAboutCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("UserAboutService_CoreData: Failed to load container")
                print("UserAboutService_CoreData-err: \(e)")
            }
        }
    }
    
    func addUserAbout(_ userAbout: UserAbout, uid: String) -> void {
        //we need to see a user with that uid already exists, if there is no user with that uid, we add it
        if !doesUserExist(uid: uid) {
            do {
                let abt = UserAboutCD(context: persistentContainer.viewContext)
                
                bundleUserAboutCD(userAbout, abtCD: abt, uid: uid)
                
                try persistentContainer.viewContext.save()
                print("UserAboutService_CoreData: Successfully added new UserAbout")
                return
            } catch {
                print("UserAboutService_CoreData: Failed to add new UserAbout: \(error)")
                return
            }
        } else {
            print("UserAboutService_CoreData: addUserAbout -> Tried to re add user")
            return
            //promise(.failure(CRUDError.triedToReAddUser))
        }
    }
    
    func getUserAbout(uid: String) -> userAbout {
        let fetchRequest: NSFetchRequest<UserAboutCD> = UserAboutCD.fetchRequest()
        let predicate = NSPredicate(format: "uid == %@", uid)
        fetchRequest.predicate = predicate
        
        do {
            let users = try persistentContainer.viewContext.fetch(fetchRequest)
            if users.count > 0 {
                let userAbout = bundleUserAbout(abt: users[0])
                print("UserAboutService_CoreData: Found UserAbout with id -> \(uid)")
                return userAbout
            } else {
                print("UserAboutService_CoreData: No UserAbout found with uid -> \(uid)")
                return nil
            }
        } catch {
            print("UserAboutService_CoreData: Failed to fetch UserAbout with uid -> \(uid)")
            return nil
        }
    }
    
    func updateUserAbout(_ userAbout: UserAbout, uid: String) -> void {
        //we only want to update our own UserCore
        //So we need to find our UserCoreCD object and update it
        if let user = getUserAboutCD(uid: uid) {
            bundleUserAboutCD(userAbout, abtCD: user, uid: uid)
            do {
                try persistentContainer.viewContext.save()
                print("UserAboutService_CoreData: Successfully updated UserAbout w/ uid -> \(uid)")
                return
            } catch {
                print("UserAboutService_CoreData: Failed to save context")
                return
            }
        } else {
            print("UserAboutService_CoreData: No user to update")
            return
        }
    }
}

extension UserAboutService_CoreData {
    func removeUser(uid: String) {
        //we need to make sure the user exists first before deleting it
        if let user = getUserAboutCD(uid: uid) {
            //delete it
            persistentContainer.viewContext.delete(user)
            
            do {
                try persistentContainer.viewContext.save()
                print("UserAboutService_CoreData: Successfully deleted UserAbout with id -> \(uid)")
                return
            } catch {
                print("UserAboutService_CoreData: Failed to save context when deleting user with id -> \(uid)")
                return
            }
        } else {
            //user does not exist
            print("UserAboutService_CoreData: There is no user to delete")
            return
        }
    }
}

extension UserAboutService_CoreData {
    
    private func getUserAboutCD(uid: String) -> UserAboutCD? {
        let fetchRequest: NSFetchRequest<UserAboutCD> = UserAboutCD.fetchRequest()
        let predicate = NSPredicate(format: "uid == %@", uid)
        fetchRequest.predicate = predicate
        
        do {
            let users = try persistentContainer.viewContext.fetch(fetchRequest)
            if users.count > 0 {
                return users[0]
            } else {
                return nil
            }
        } catch {
            print("UserCorePersistence: Could not find UserCoreCD w uid: \(uid)")
            return nil
        }
    }
    
    func bundleUserAboutCD(_ abt: UserAbout, abtCD: UserAboutCD, uid: String) {
        abtCD.uid = uid
        abtCD.bio = abt.bio
        abtCD.job = abt.job
        abtCD.school = abt.school
    }
    
    func bundleUserAbout(abt: UserAboutCD) -> UserAbout {
        return UserAbout(bio: abt.bio, job: abt.job, school: abt.school)
    }
    
    func doesUserExist(uid: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<UserAboutCD> = UserAboutCD.fetchRequest()
        let predicate = NSPredicate(format: "uid == %@", uid)
        fetchRequest.predicate = predicate
        
        do {
            let users = try persistentContainer.viewContext.fetch(fetchRequest)
            if users.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
