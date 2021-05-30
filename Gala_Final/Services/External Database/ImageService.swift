//
//  ImageService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-05.
//

import Combine
import SwiftUI
import FirebaseStorage

//Rename to ProfileImageService
protocol ProfileImageServiceProtocol {
    func uploadProfileImage(img: ImageModel, name: String) -> AnyPublisher<Void, Error> 
    func getProfileImage(name: String) -> AnyPublisher<UIImage?, Error>
    func deleteProfileImage(name: String) ->AnyPublisher<Void, Error>
}

class ProfileImageService: ProfileImageServiceProtocol{
    
    private let storage = Storage.storage()
    private let currentUser = UserService.shared.currentUser?.uid
    
    func uploadProfileImage(img: ImageModel, name: String) -> AnyPublisher<Void, Error> {
        let data = img.image.jpegData(compressionQuality: compressionQuality)!
        let storageRef = storage.reference()
        let profileFolder = "ProfileImages"
        let profileRef = storageRef.child(profileFolder)
        let myProfileRef = profileRef.child(currentUser!)
        let imgFileRef = myProfileRef.child("\(name).png")
        
        return Future<Void, Error> { promise in
            let _ = imgFileRef.putData(data, metadata: nil) { (metaData, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    return promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getProfileImage(name: String) -> AnyPublisher<UIImage?, Error> {
        let storageRef = storage.reference()
        let profileRef = storageRef.child("ProfileImages")
        let myProfileRef = profileRef.child(currentUser!)
        let imgFileRef = myProfileRef.child("\(name).png")
        
        return Future<UIImage?, Error> { promise in
            imgFileRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
                if let error = error {
                    promise(.failure(error))
                }
                
                if let data = data {
                    let img = UIImage(data: data)
                    promise(.success(img))
                } else {
                    promise(.success(nil))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteProfileImage(name: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
