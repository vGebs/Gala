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
        persistentContainer = NSPersistentContainer(name: "UserAbout_CoreData")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("UserAboutPersistence: Failed to load persistent stores")
                print("UserAboutPersistence-err: \(e)")
            }
        }
    }
    
    func addUserAbout(_ userAbout: UserAbout) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func getUserAbout(uid: String) -> AnyPublisher<UserAbout?, Error> {
        return Future<UserAbout?, Error> { promise in
            promise(.success(nil))
        }.eraseToAnyPublisher()
    }
}
