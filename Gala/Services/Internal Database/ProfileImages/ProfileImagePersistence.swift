//
//  ProfileImagePersistence.swift
//  Gala
//
//  Created by Vaughn on 2022-04-04.
//

import Foundation
import Combine
import CoreData
import UIKit

class ProfileImagePersistence: ProfileImageServiceProtocol {
    
    let persistentContainer: NSPersistentContainer
    
    static let shared = ProfileImagePersistence()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ProfileImages_CoreData")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("ProfileImagePersistence: Failed to load persistent stores")
                print("ProfileImagePersistence-err: \(e)")
            }
        }
    }
    
    func uploadProfileImage(img: ImageModel, name: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func uploadProfileImages(imgs: [ImageModel]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func getProfileImage(id: String, index: String) -> AnyPublisher<UIImage?, Error> {
        return Future<UIImage?, Error> { promise in
            promise(.success(nil))
        }.eraseToAnyPublisher()
    }
    
    func deleteProfileImage(index: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}
