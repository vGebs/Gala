//
//  ImageService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-05.
//

import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class ProfileImageService_Firebase: ProfileImageServiceProtocol {
    
    typealias void = AnyPublisher<Void, Error>
    typealias image = AnyPublisher<UIImage?, Error>
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()

    static let shared = ProfileImageService_Firebase()
    private var cancellables: [AnyCancellable] = []
    
    private init() {  }
    
    func uploadProfileImage(uid: String, img: ImageModel) -> void {
        if img.index == 0 {
            return Future<Void, Error> { [weak self] promise in
                Publishers
                    .Zip(
                        self!.uploadProfileImage_(uid: uid, img: img),
                        self!.uploadUpdateDocument(for: uid)
                    )
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileImageService_Firebase: Failed to upload img and update document")
                            print("ProfileImageService_Firebase: \(e)")
                            promise(.failure(e))
                        case .finished:
                            print("ProfileImageService_Firebase: Finished pushing img and update doc")
                            promise(.success(()))
                        }
                    } receiveValue: { (_, _) in }
                    .store(in: &self!.cancellables)
            }.eraseToAnyPublisher()
        } else {
            return uploadProfileImage_(uid: uid, img: img)
        }
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
        if index == "0" {
            return Future<Void, Error> { [weak self] promise in
                Publishers
                    .Zip(
                        self!.deleteProfileImage_(uid: uid, index: index),
                        self!.uploadUpdateDocument(for: uid)
                    )
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileImageService_Firebase: Failed to delete img and update document")
                            print("ProfileImageService_Firebase: \(e)")
                            promise(.failure(e))
                        case .finished:
                            print("ProfileImageService_Firebase: Finished deleting img and updating doc")
                            promise(.success(()))
                        }
                    } receiveValue: { (_, _) in }
                    .store(in: &self!.cancellables)
            }.eraseToAnyPublisher()
        } else {
            return deleteProfileImage_(uid: uid, index: index)
        }
    }
}

extension ProfileImageService_Firebase {
    func observeProfileImage(for uid: String, promise: @escaping (UIImage?, Bool) -> Void) {
        db.collection("ProfileImageUpdate").document(uid)
            .addSnapshotListener { [weak self] snapShot, error in
                guard let _ = snapShot?.data() else {
                    promise(nil, false)
                    return
                }
                
                self?.getProfileImage(uid: uid, index: "0")
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileImageService_Firebase: Failed to listen for profile image updates")
                            print("ProfileImageService_Firebase-err: \(e)")
                            promise(nil, false)
                        case .finished:
                            print("ProfileImageService_Firebase: Finished getting updates profile img")
                        }
                    }, receiveValue: { img in
                        if let img = img {
                            promise(img, false)
                        } else {
                            promise(nil, true)
                        }
                    }).store(in: &self!.cancellables)
            }
    }
}

extension ProfileImageService_Firebase {
    private func uploadProfileImage_(uid: String, img: ImageModel) -> void {
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
    
    private func deleteProfileImage_(uid: String, index: String) -> void {
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
    
    private func uploadUpdateDocument(for uid: String) -> void {
        return Future<Void, Error> { [weak self] promise in
            self!.db.collection("ProfileImageUpdate").document(uid).setData([
                "lastUpdated": Date()
            ]) { err in
                if let e = err {
                    promise(.failure(e))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
