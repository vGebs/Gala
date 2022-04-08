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

class UserCorePersistence: UserCoreServiceProtocol {
    
    let persistentContainer: NSPersistentContainer
    
    static let shared = UserCorePersistence()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "UserCoreCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("UserCorePersistence: Failed to load container")
                print("UserCorePersistence-err: \(e)")
            }
        }
    }
    
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            //we need to see a user with that uid already exists, if there is no user with that uid, we add it
            if !self!.doesUserExist(uid: core.userBasic.uid) {
                do {
                    let uc = UserCoreCD(context: self!.persistentContainer.viewContext)
                    
                    self!.bundleUserCoreCD(uc: core, ucCD: uc)
                    
                    try self!.persistentContainer.viewContext.save()
                    print("UserCorePersistence: Successfully added new UserCore")
                    promise(.success(()))
                } catch {
                    print("UserCorePersistence: Failed to add new UserCore: \(error)")
                    promise(.failure(error))
                }
            } else {
                promise(.failure(CRUDError.triedToReAddUser))
            }
        }.eraseToAnyPublisher()
    }
    
    func getUserCore(uid: String?) -> AnyPublisher<UserCore?, Error> {
        return Future<UserCore?, Error> { [weak self] promise in
            if let uid = uid {
                let fetchRequest: NSFetchRequest<UserCoreCD> = UserCoreCD.fetchRequest()
                let predicate = NSPredicate(format: "uid == %@", uid)
                fetchRequest.predicate = predicate
                
                do {
                    let users = try self!.persistentContainer.viewContext.fetch(fetchRequest)
                    if users.count > 0 {
                        let userCore = self!.bundleUserCore(uc: users[0])
                        promise(.success(userCore))
                    } else {
                        print("UserCoreService: No UserCore found with uid -> \(uid)")
                        promise(.failure(CRUDError.noDocumentFound))
                    }
                } catch {
                    print("UserCoreService: Failed to fetch UserCore with uid -> \(uid)")
                    promise(.failure(CRUDError.failedToFetch))
                }
            } else {
                print("UserCoreService: Empty uid input")
                promise(.failure(CRUDError.uidEmpty))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateUser(userCore: UserCore) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            //we only want to update our own UserCore
            //So we need to find our UserCoreCD object and update it
            if let user = self!.getUserCoreCD(uid: userCore.userBasic.uid) {
                self!.bundleUserCoreCD(uc: userCore, ucCD: user)
                do {
                    try self!.persistentContainer.viewContext.save()
                    print("UserCorePersistence: Successfully updated UserCore w/ uid -> \(userCore.userBasic.uid)")
                    promise(.success(()))
                } catch {
                    print("UserCorePersistence: Failed to save context")
                    promise(.failure(error))
                }
            } else {
                promise(.failure(CRUDError.noUserToUpdate))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            //we need to make sure the user exists first before deleting it
            if let user = self!.getUserCoreCD(uid: uid) {
                //delete it
                self!.persistentContainer.viewContext.delete(user)
                
                do {
                    try self!.persistentContainer.viewContext.save()
                    print("UserCorePersistence: Successfully deleted user with id -> \(uid)")
                    promise(.success(()))
                } catch {
                    print("UserCorePersistence: Failed to save context")
                    promise(.failure(error))
                }
            } else {
                //user does not exist
                promise(.failure(CRUDError.noUserToDelete))
            }
        }.eraseToAnyPublisher()
    }
}

extension UserCorePersistence {
    
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
            print("UserCorePersistence: Could not find UserCoreCD w uid: \(uid)")
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
