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
    
    private var subs: [AnyCancellable] = []
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ProfileImageCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("ProfileImagePersistence: Failed to load container")
                print("ProfileImagePersistence-err: \(e)")
            }
        }
    }
    
    func uploadProfileImage(uid: String, img: ImageModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            //when we upload an image, we need to make sure that:
            //  1. There isnt an image w the same uid and index
            //      a. if there is an image at that index with the same uid, we delete the old and input the new
            //      b. if there is not an image at the same index witht the same uid, we just push it
            if let imgToDelete = self!.getProfileImageCD(uid: uid, index: String(img.index)) {
                self!.deleteImage(img: imgToDelete)
                
                do {
                    let imgCD = ProfileImageCD(context: self!.persistentContainer.viewContext)
                    
                    self!.bundleProfileImage(uid: uid, imgModel: img, imgCD: imgCD)
                    
                    try self!.persistentContainer.viewContext.save()
                    print("ProfileImagePersistence: Successfully added new ImageModel")
                    promise(.success(()))
                    
                } catch {
                    print("ProfileImagePersistence: Failed to add new ImageModel: \(error)")
                    promise(.failure(error))
                }
                
            } else {
                do {
                    let imgCD = ProfileImageCD(context: self!.persistentContainer.viewContext)
                    
                    self!.bundleProfileImage(uid: uid, imgModel: img, imgCD: imgCD)
                    
                    try self!.persistentContainer.viewContext.save()
                    print("ProfileImagePersistence: Successfully added new ImageModel")
                    promise(.success(()))
                    
                } catch {
                    print("ProfileImagePersistence: Failed to add new ImageModel: \(error)")
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func uploadProfileImages(uid: String, imgs: [ImageModel]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            for i in 0..<imgs.count {
                self!.uploadProfileImage(uid: uid, img: imgs[i])
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("ProfileImagePersistence-uploadProfileImages index: \(String(i)) failed: \(error.localizedDescription)")
                            if i == (imgs.count - 1){
                                promise(.success(()))
                            }
                        case .finished:
                            print("ProfileImagePersistence-uploadProfile: image i=\(String(i)) successfully added")
                            if i == (imgs.count - 1){
                                promise(.success(()))
                            }
                        }
                    } receiveValue: { _ in }
                    .store(in: &self!.subs)
            }
        }.eraseToAnyPublisher()
    }
    
    func getProfileImage(uid: String, index: String) -> AnyPublisher<UIImage?, Error> {
        return Future<UIImage?, Error> { [weak self] promise in
            if let img = self!.getProfileImageCD(uid: uid, index: index) {
                let imgFinal = UIImage(data: img.img!)
                
                promise(.success(imgFinal))
            } else {
                //promise(.failure(CRUDError.noDocumentFound))
                print("ProfileImagePersistence: Failed to find profile img")
                promise(.success(nil))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteProfileImage(uid: String, index: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            if let img = self!.getProfileImageCD(uid: uid, index: index) {
                
                self!.deleteImage(img: img)
                promise(.success(()))
            } else {
                promise(.failure(CRUDError.noDocumentFound))
            }
        }.eraseToAnyPublisher()
    }
}

extension ProfileImagePersistence {
    
    //We just changed index to string, make sure we make index a string everywhere in this file
    private func getProfileImageCD(uid: String, index: String) -> ProfileImageCD? {
        let fetchRequest: NSFetchRequest<ProfileImageCD> = ProfileImageCD.fetchRequest()
        
        let uidPredicate = NSPredicate(format: "uid == %@", uid)
        let indexPredicate = NSPredicate(format: "index == %@", index)
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [uidPredicate, indexPredicate])
        
        fetchRequest.predicate = andPredicate
        
        do {
            let imgs = try persistentContainer.viewContext.fetch(fetchRequest)
            if imgs.count > 0 {
                print("ProfileImagePersistence: Found img with index -> \(index)")
                return imgs[0]
            } else {
                print("ProfileImagePersistence: Could not find img w uid: \(uid), and index: \(index)")
                return nil
            }
        } catch {
            print("ProfileImagePersistence: Could not find img w uid: \(uid), and index: \(index)")
            return nil
        }
    }
    
    private func deleteImage(img: ProfileImageCD) {
        persistentContainer.viewContext.delete(img)
        
        do {
            try persistentContainer.viewContext.save()
            print("UserCorePersistence: Successfully deleted img with index -> \(String(describing: img.index))")
        } catch {
            print("UserCorePersistence: Failed to save context")
        }
    }
    
    private func bundleProfileImage(uid: String, imgModel: ImageModel, imgCD: ProfileImageCD) {
        imgCD.uid = uid
        imgCD.index = String(imgModel.index)
        
        let data = imgModel.image.jpegData(compressionQuality: compressionQuality)!
        imgCD.img = data
    }
}
