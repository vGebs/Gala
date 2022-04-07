//
//  UserCorePersistence.swift
//  Gala
//
//  Created by Vaughn on 2022-03-31.
//

import Foundation
import CoreData
import Combine

//For the UserCore persistence, we will need to be able:
//  1. To Create a new User
//  2. To fetch users with id
//  3. To delete users with id (our matches have a UserCore and if we unmatch, then we need to delete them)
//  4. To Update users profiles. If there is an updated version of one of our matches profiles, we need to update them; as well as our own

class UserCorePersistence: UserCoreServiceProtocol {
    
    let persistentContainer: NSPersistentContainer

    static let shared = UserCorePersistence()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "UserCore_CoreData")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("UserCorePersistence: Failed to load persistent stores")
                print("UserCorePersistence-err: \(e)")
            }
        }
    }
    
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error> {

//        let privateContext = persistentContainer.newBackgroundContext()
//
//        let uc = UserCorePersisted(context: privateContext)

        return Future<Void, Error> { promise in
            
            promise(.success(()))
//            uc.uid = user.uid
//            uc.birthdate = user.age
//            uc.name = user.name
//            uc.gender = user.gender
//            uc.sexuality = user.sexuality
//            uc.ageMinPref = Int16(user.ageMinPref)
//            uc.ageMaxPref = Int16(user.ageMaxPref)
//            uc.willingToTravel = Int16(user.willingToTravel)
            
//            do {
//                try privateContext.save()
//                promise(.success(()))
//            } catch {
//                print("UserCorePersistence: Failed to save new UserCore")
//                print("UserCorePersistence-err: \(error)")
//                promise(.failure(error))
//            }
        }.eraseToAnyPublisher()
    }
    
    func updateUser(userCore: UserCore, uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            promise(.success(()))
            //we need to fetch the user with the given id
            
//            var userToUpdate: UserCorePersisted?
//
//            if let users = self?.simpleGet(uid: uid) {
//                for user in users {
//                    if user.uid == uid {
//                        userToUpdate = user
//                        break
//                    }
//                }
//
//                if let u = userToUpdate {
//                    u.uid = userCore.uid
//                    u.birthdate = userCore.age
//                    u.name = userCore.name
//                    u.gender = userCore.gender
//                    u.sexuality = userCore.sexuality
//                    u.ageMinPref = Int16(userCore.ageMinPref)
//                    u.ageMaxPref = Int16(userCore.ageMaxPref)
//                    u.willingToTravel = Int16(userCore.willingToTravel)
//                    u.longitude = userCore.longitude
//                    u.latitude = userCore.latitude
                    
//                    do {
//                        try self!.persistentContainer.viewContext.save()
//                    } catch {
//                        self!.persistentContainer.viewContext.rollback()
//                    }
//
//                }
//            }
            
        }.eraseToAnyPublisher()
    }
    
    func getUserCore(uid: String?) -> AnyPublisher<UserCore?, Error> {
        return Future<UserCore?, Error> { promise in
            promise(.success(nil))
        }.eraseToAnyPublisher()
    }
}

