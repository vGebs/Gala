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
    func uploadProfileImages(imgs: [ImageModel]) -> AnyPublisher<Void, Error>
    func getProfileImage(id: String, index: String) -> AnyPublisher<UIImage?, Error>
    func deleteProfileImage(name: String) ->AnyPublisher<Void, Error>
}

class ProfileImageService: ProfileImageServiceProtocol{
    
    private let storage = Storage.storage()
    private let currentUser = AuthService.shared.currentUser?.uid
    
    static let shared = ProfileImageService()
    private var cancellables: [AnyCancellable] = []
    
    private init() {  }
    
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
    
    func uploadProfileImages(imgs: [ImageModel]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            if imgs.count == 0 {
                promise(.success(()))
            } else {
                for i in 0..<imgs.count {
                    self.uploadProfileImage(img: imgs[i], name: String(i))
                        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                        .sink { completion in
                            switch completion {
                            case .failure(let error):
                                print("ImageService-uploadProfileImages index: \(String(i)) failed: \(error.localizedDescription)")
                            case .finished:
                                print("ImageService-uploadProfile: image i=\(String(i)) successfully added")
                                if i == (imgs.count - 1){
                                    promise(.success(()))
                                }
                            }
                        } receiveValue: { _ in }
                        .store(in: &self.cancellables)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getProfileImage(id: String, index: String) -> AnyPublisher<UIImage?, Error> {
        let storageRef = storage.reference()
        let profileRef = storageRef.child("ProfileImages")
        let myProfileRef = profileRef.child(id)
        let imgFileRef = myProfileRef.child("\(index).png")
        
        return Future<UIImage?, Error> { promise in
            imgFileRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Non lethal fetching error (ImageService): \(error.localizedDescription)")
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
    
    //Function is not being used yet.
    //Images are not being retrieved with id so we cannot delete the correct image
    //P.S., this function should work tho assuming proper input
    func deleteProfileImage(name: String) -> AnyPublisher<Void, Error> {
        let uid = currentUser!
        let storageRef = storage.reference()
        let profileRef = storageRef.child("ProfileImages")
        let myProfileRef = profileRef.child(uid)
        let imgFileRef = myProfileRef.child("\(name).png")
        
        return Future<Void, Error> { promise in
            imgFileRef.delete { err in
                if let err = err {
                    print("ImageService: Failed to delete image with id: \(name)")
                    print("ImageService-err: \(err)")
                } else {
                    print("ImageService: Successfully deleted image with id: \(name)")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
