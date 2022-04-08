//
//  UserAboutPersistence.swift
//  Gala
//
//  Created by Vaughn on 2022-04-04.
//

import Foundation
import CoreData
import Combine


class UserAboutPersistence: UserAboutServiceProtocol {
    
    let persistentContainer: NSPersistentContainer
    
    static let shared = UserAboutPersistence()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "UserAboutCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("UserAboutPersistence: Failed to load container")
                print("UserAboutPersistence-err: \(e)")
            }
        }
    }
    
    func addUserAbout(_ userAbout: UserAbout, uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            //we need to see a user with that uid already exists, if there is no user with that uid, we add it
            if !self!.doesUserExist(uid: uid) {
                do {
                    let abt = UserAboutCD(context: self!.persistentContainer.viewContext)
                    
                    self!.bundleUserAboutCD(userAbout, abtCD: abt)
                    
                    try self!.persistentContainer.viewContext.save()
                    print("UserAboutPersistence: Successfully added new UserCore")
                    promise(.success(()))
                } catch {
                    print("UserAboutPersistence: Failed to add new UserCore: \(error)")
                    promise(.failure(error))
                }
            } else {
                promise(.failure(CRUDError.triedToReAddUser))
            }
        }.eraseToAnyPublisher()
    }
    
    func getUserAbout(uid: String) -> AnyPublisher<UserAbout?, Error> {
        return Future<UserAbout?, Error> { [weak self] promise in
            let fetchRequest: NSFetchRequest<UserAboutCD> = UserAboutCD.fetchRequest()
            let predicate = NSPredicate(format: "uid == %@", uid)
            fetchRequest.predicate = predicate
            
            do {
                let users = try self!.persistentContainer.viewContext.fetch(fetchRequest)
                if users.count > 0 {
                    let userAbout = self!.bundleUserAbout(abt: users[0])
                    promise(.success(userAbout))
                } else {
                    print("UserAboutService: No UserAbout found with uid -> \(uid)")
                    promise(.failure(CRUDError.noDocumentFound))
                }
            } catch {
                print("UserAboutService: Failed to fetch UserAbout with uid -> \(uid)")
                promise(.failure(CRUDError.failedToFetch))
            }
            
        }.eraseToAnyPublisher()
    }
    
    func updateUserAbout(_ userAbout: UserAbout, uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            //we only want to update our own UserCore
            //So we need to find our UserCoreCD object and update it
            if let user = self!.getUserAboutCD(uid: uid) {
                self!.bundleUserAboutCD(userAbout, abtCD: user)
                do {
                    try self!.persistentContainer.viewContext.save()
                    print("UserAboutPersistence: Successfully updated UserAbout w/ uid -> \(uid)")
                    promise(.success(()))
                } catch {
                    print("UserAboutPersistence: Failed to save context")
                    promise(.failure(error))
                }
            } else {
                promise(.failure(CRUDError.noUserToUpdate))
            }
        }.eraseToAnyPublisher()
    }
}

extension UserAboutPersistence {
    
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
    
    func bundleUserAboutCD(_ abt: UserAbout, abtCD: UserAboutCD) {
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
