//
//  UserCorePersistence.swift
//  Gala
//
//  Created by Vaughn on 2022-03-31.
//

import Foundation
import CoreData
import Combine

enum CRUDError: Error {
    case uidEmpty
    case noDocumentFound
    case failedToFetch
    case triedToReAddUser
    case noUserToUpdate
    case noUserToDelete
}

class UserCoreService_CoreData: UserCoreServiceProtocol {
    typealias void = Void
    typealias userCore = UserCore?
    
    static let shared = UserCoreService_CoreData()
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "UserCoreCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("UserCoreService_CoreData: Failed to load container")
                print("UserCoreService_CoreData-err: \(e)")
            }
        }
    }
    
    func addNewUser(core: UserCore) -> Void {
        if !doesUserExist(uid: core.userBasic.uid) {
            do {
                let uc = UserCoreCD(context: persistentContainer.viewContext)
                
                bundleUserCoreCD(uc: core, ucCD: uc)
                
                try persistentContainer.viewContext.save()
                print("UserCoreService_CoreData: Successfully added new UserCore")
                return
            } catch {
                //we should probably do something here such as retry
                print("UserCoreService_CoreData: Failed to add new UserCore: \(error)")
                return
            }
        } else {
            print("UserCoreService_CoreData: Tried to re-add User")
            return
        }
    }
    
    func updateUser(userCore: UserCore) -> Void {
        if let user = getUserCoreCD(uid: userCore.userBasic.uid) {
            bundleUserCoreCD(uc: userCore, ucCD: user)
            do {
                try persistentContainer.viewContext.save()
                print("UserCoreService_CoreData: Successfully updated UserCore w/ uid -> \(userCore.userBasic.uid)")
                return
            } catch {
                print("UserCoreService_CoreData: Failed to save context")
                return
            }
        } else {
            print("UserCoreService_CoreData: No user to update")
        }
    }
    
    func getUserCore(uid: String?) -> UserCore? {
        if let uid = uid {
            let fetchRequest: NSFetchRequest<UserCoreCD> = UserCoreCD.fetchRequest()
            let predicate = NSPredicate(format: "uid == %@", uid)
            fetchRequest.predicate = predicate
            
            do {
                let users = try persistentContainer.viewContext.fetch(fetchRequest)
                if users.count > 0 {
                    let userCore = bundleUserCore(uc: users[0])
                    print("UserCoreService_CoreData: returning userCore w/ uid -> \(uid)")
                    return userCore
                } else {
                    print("UserCoreService_CoreData: No UserCore found with uid -> \(uid)")
                    return nil
                }
            } catch {
                print("UserCoreService_CoreData: Failed to fetch UserCore with uid -> \(uid)")
                return nil
            }
        } else {
            print("UserCoreService_CoreData: Empty uid input")
            return nil
        }
    }
    
    func clear() {
        let users = getAllUsers()
        
        for user in users {
            self.removeUser(uid: user.userBasic.uid)
        }
    }
}

extension UserCoreService_CoreData {
    
    private func getAllUsers() -> [UserCore] {
        let fetchRequest: NSFetchRequest<UserCoreCD> = UserCoreCD.fetchRequest()
        
        do {
            let userCoreCD = try persistentContainer.viewContext.fetch(fetchRequest)
            
            var users: [UserCore] = []
            
            for user in userCoreCD {
                users.append(bundleUserCore(uc: user))
            }
            
            return users
        } catch {
            
            print("UserCoreService_CoreData: Failed to fetch all users")
            print("UserCoreService_CoreData: Failed to save context")
            
            return []
        }
    }
    
    func removeUser(uid: String) {
        //we need to make sure the user exists first before deleting it
        if let user = getUserCoreCD(uid: uid) {
            //delete it
            persistentContainer.viewContext.delete(user)
            
            do {
                try persistentContainer.viewContext.save()
                print("UserCoreService_CoreData: Successfully deleted user with id -> \(uid)")
                return
            } catch {
                print("UserCoreService_CoreData: Failed to save context")
                return
            }
        } else {
            //user does not exist
            print("UserCoreService_CoreData: There is no user to delete")
            return
        }
    }
}

extension UserCoreService_CoreData {
    
    private func getUserCoreCD(uid: String) -> UserCoreCD? {
        let fetchRequest: NSFetchRequest<UserCoreCD> = UserCoreCD.fetchRequest()
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
            print("UserCoreService_CoreData: Could not find UserCoreCD w uid: \(uid)")
            return nil
        }
    }
    
    private func doesUserExist(uid: String) -> Bool {
        let fetchRequest: NSFetchRequest<UserCoreCD> = UserCoreCD.fetchRequest()
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
    
    private func bundleUserCore(uc: UserCoreCD) -> UserCore {
        let basic = UserBasic(
            uid: uc.uid!,
            name: uc.name!,
            birthdate: uc.birthdate!,
            gender: uc.gender!,
            sexuality: uc.sexuality!
        )
        
        let agePref = AgeRangePreference(minAge: Int(uc.ageMinPref), maxAge: Int(uc.ageMaxPref))
        
        let search = SearchRadiusComponents(
            coordinate: Coordinate(
                lat: uc.latitude,
                lng: uc.longitude
            ),
            willingToTravel: Int(uc.willingToTravel)
        )
        
        let userCoreFinal = UserCore(
            userBasic: basic,
            ageRangePreference: agePref,
            searchRadiusComponents: search
        )
        return userCoreFinal
    }
    
    private func bundleUserCoreCD(uc: UserCore, ucCD: UserCoreCD) {
        ucCD.uid = uc.userBasic.uid
        ucCD.name = uc.userBasic.name
        ucCD.birthdate = uc.userBasic.birthdate
        ucCD.gender = uc.userBasic.gender
        ucCD.sexuality = uc.userBasic.sexuality
        
        ucCD.ageMaxPref = Int16(uc.ageRangePreference.maxAge)
        ucCD.ageMinPref = Int16(uc.ageRangePreference.minAge)
        
        ucCD.willingToTravel = Int16(uc.searchRadiusComponents.willingToTravel)
        ucCD.latitude = uc.searchRadiusComponents.coordinate.lat
        ucCD.longitude = uc.searchRadiusComponents.coordinate.lng
    }
}
