//
//  ProfileImageService.swift
//  Gala
//
//  Created by Vaughn on 2022-04-19.
//

import Foundation
import Combine
import SwiftUI

protocol ProfileImageServiceProtocol {
    associatedtype void
    associatedtype image
    
    func uploadProfileImage(uid: String, img: ImageModel) -> void
    func uploadProfileImages(uid: String, imgs: [ImageModel]) -> void
    func getProfileImage(uid: String, index: String) -> image
    func deleteProfileImage(uid: String, index: String) -> void
}

class ProfileImageService: ProfileImageServiceProtocol {
    typealias void = AnyPublisher<Void, Error>
    typealias image = AnyPublisher<UIImage?, Error>
    
    static let shared = ProfileImageService()
    
    private let firebase: ProfileImageService_Firebase
    private let coreData: ProfileImageService_CoreData
    
    private init() {
        firebase = ProfileImageService_Firebase.shared
        coreData = ProfileImageService_CoreData.shared
    }
    
    private var subs: [AnyCancellable] = []
    
    func uploadProfileImage(uid: String, img: ImageModel) -> void {
        return Future<Void, Error> { [weak self] promise in
            //we need to push the image to firestore before pushing to core data
            self?.firebase.uploadProfileImage(uid: uid, img: img)
                .map{ [weak self] _ in
                    self!.coreData.uploadProfileImage(uid: uid, img: img)
                }
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ProfileImageService: Failed to upload img w/ id -> \(uid), and index -> \(img.index)")
                        print("ProfileImageService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("ProfileImageService: Finished uploading img w/ id -> \(uid), and index -> \(img.index)")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }.eraseToAnyPublisher()
    }
    
    func uploadProfileImages(uid: String, imgs: [ImageModel]) -> void {
        return Future<Void, Error> { [weak self] promise in
            self?.firebase.uploadProfileImages(uid: uid, imgs: imgs)
                .map{ [weak self] _ in
                    self!.coreData.uploadProfileImages(uid: uid, imgs: imgs)
                }
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ProfileImageService: Failed to upload imgs w/ id -> \(uid)")
                        print("ProfileImageService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("ProfileImageService: Finished uploading img w/ id -> \(uid)")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }.eraseToAnyPublisher()
    }
    
    func getProfileImage(uid: String, index: String) -> image {
        return Future<UIImage?, Error> { [weak self] promise in
            //check coreData, if coredata has nothing, check firestore
            if let img = self?.coreData.getProfileImage(uid: uid, index: index) {
                print("ProfileImageService: Successfully fetched img w/ id -> \(uid), and index -> \(index)")
                return promise(.success(img))
            } else {
                self?.firebase.getProfileImage(uid: uid, index: index)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileImageService: Failed to get img w/ id -> \(uid), and index -> \(index)")
                            print("ProfileImageService-err: \(e)")
                            promise(.failure(e))
                        case .finished:
                            print("ProfileImageService: Successfully fetched img w/ id -> \(uid), and index -> \(index)")
                        }
                    }, receiveValue: { [weak self] img in
                        //if we get an image back from firebase and the uid matches the current uid, we need to put it in CoreData
                        if uid == AuthService.shared.currentUser!.uid {
                            if let img = img {
                                if let i = Int(index) {
                                    let imgModel = ImageModel(image: img, index: i)
                                    self?.coreData.uploadProfileImage(uid: uid, img: imgModel)
                                }
                            }
                        }
                        
                        promise(.success(img))
                    }).store(in: &self!.subs)
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteProfileImage(uid: String, index: String) -> void {
        return Future<Void, Error> { [weak self] promise in
            //we want to delete firestore data before core data
            self?.firebase.deleteProfileImage(uid: uid, index: index)
                .map{ [weak self] _ in
                    self!.coreData.deleteProfileImage(uid: uid, index: index)
                }
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ProfileImageService: Failed to delete img w/ id -> \(uid) & index -> \(index)")
                        print("ProfileImageService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("ProfileImageService: Finished deleting img w/ id -> \(uid) & index -> \(index)")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }.eraseToAnyPublisher()
    }
}
