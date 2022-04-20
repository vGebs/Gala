//
//  ImageService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-05.
//

import Combine
import SwiftUI
import FirebaseStorage

class ProfileImageService_Firebase: ProfileImageServiceProtocol {
    
    typealias void = AnyPublisher<Void, Error>
    typealias image = AnyPublisher<UIImage?, Error>
    
    private let storage = Storage.storage()
    
    static let shared = ProfileImageService_Firebase()
    private var cancellables: [AnyCancellable] = []
    
    private init() {  }
    
    func uploadProfileImage(uid: String, img: ImageModel) -> void {
        let data = img.image.jpegData(compressionQuality: compressionQuality)!
        let storageRef = storage.reference()
        let profileFolder = "ProfileImages"
        let profileRef = storageRef.child(profileFolder)
        let myProfileRef = profileRef.child(AuthService.shared.currentUser!.uid)
        let imgFileRef = myProfileRef.child("\(img.index).png")
        
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
    
    func uploadProfileImages(uid: String, imgs: [ImageModel]) -> void {
        return Future<Void, Error> { promise in
            if imgs.count == 0 {
                promise(.success(()))
            } else {
                for i in 0..<imgs.count {
                    self.uploadProfileImage(uid: uid, img: imgs[i])
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
    
    func getProfileImage(uid: String, index: String) -> image {
        let storageRef = storage.reference()
        let profileRef = storageRef.child("ProfileImages")
        let myProfileRef = profileRef.child(uid)
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
    
    func deleteProfileImage(uid: String, index: String) -> void {
        let storageRef = storage.reference()
        let profileRef = storageRef.child("ProfileImages")
        let myProfileRef = profileRef.child(uid)
        let imgFileRef = myProfileRef.child("\(index).png")
        
        return Future<Void, Error> { promise in
            imgFileRef.delete { err in
                if let err = err {
                    print("ImageService: Failed to delete image with id: \(index)")
                    print("ImageService-err: \(err)")
                    promise(.success(()))
                } else {
                    print("ImageService: Successfully deleted image with id: \(index)")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
