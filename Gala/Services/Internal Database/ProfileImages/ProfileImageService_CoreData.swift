//
//  ProfileImageService_CoreData.swift
//  Gala
//
//  Created by Vaughn on 2022-04-19.
//

import Foundation
import CoreData
import SwiftUI
import Combine

class ProfileImageService_CoreData: ProfileImageServiceProtocol {
    
    typealias void = Void
    typealias image = UIImage?
    
    let persistentContainer: NSPersistentContainer
    
    static let shared = ProfileImageService_CoreData()
    
    private var subs: [AnyCancellable] = []
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ProfileImageCD")
        persistentContainer.loadPersistentStores { description, err in
            if let e = err {
                print("ProfileImageService_CoreData: Failed to load container")
                print("ProfileImageService_CoreData-err: \(e)")
            }
        }
    }
    
    func uploadProfileImage(uid: String, img: ImageModel) -> void {
        //when we upload an image, we need to make sure that:
        //  1. There isnt an image w the same uid and index
        //      a. if there is an image at that index with the same uid, we delete the old and input the new
        //      b. if there is not an image at the same index witht the same uid, we just push it
        if let imgToDelete = getProfileImageCD(uid: uid, index: String(img.index)) {
            deleteImage(img: imgToDelete)
            
            do {
                let imgCD = ProfileImageCD(context: persistentContainer.viewContext)
                
                bundleProfileImage(uid: uid, imgModel: img, imgCD: imgCD)
                
                try persistentContainer.viewContext.save()
                print("ProfileImageService_CoreData: Successfully added new ImageModel")
                return
            } catch {
                print("ProfileImageService_CoreData: Failed to add new ImageModel: \(error)")
                return
            }
            
        } else {
            do {
                let imgCD = ProfileImageCD(context: persistentContainer.viewContext)
                
                bundleProfileImage(uid: uid, imgModel: img, imgCD: imgCD)
                
                try persistentContainer.viewContext.save()
                print("ProfileImageService_CoreData: Successfully added new ImageModel")
                return
                
            } catch {
                print("ProfileImageService_CoreData: Failed to add new ImageModel: \(error)")
                return
            }
        }
    }
    
    func uploadProfileImages(uid: String, imgs: [ImageModel]) -> void {
        for i in 0..<imgs.count {
            uploadProfileImage(uid: uid, img: imgs[i])
        }
    }
    
    func getProfileImage(uid: String, index: String) -> image {
        if let img = getProfileImageCD(uid: uid, index: index) {
            let imgFinal = UIImage(data: img.img!)
            
            return imgFinal
        } else {
            print("ProfileImageService_CoreData: No profile image found")
            return nil
        }
    }
    
    func deleteProfileImage(uid: String, index: String) -> void {
        if let img = getProfileImageCD(uid: uid, index: index) {
            
            deleteImage(img: img)
        } else {
            print("ProfileImageService_CoreData: No document to delete")
            return
        }
    }
}

extension ProfileImageService_CoreData {
    func getAllProfileImages(uid: String) -> [ImageModel]? {
        if let imgs = getAllProfileImagesCD(uid: uid) {
            var final: [ImageModel] = []
            
            for img in imgs {
                let tempImg = UIImage(data: img.img!)
                let im = ImageModel(image: tempImg!, index: Int(img.index!)!)
                final.append(im)
            }
            return final
        } else {
            return nil
        }
    }
    
    private func getAllProfileImagesCD(uid: String) -> [ProfileImageCD]? {
        let fetchRequest: NSFetchRequest<ProfileImageCD> = ProfileImageCD.fetchRequest()
        
        let predicate = NSPredicate(format: "uid == %@", uid)
        
        fetchRequest.predicate = predicate
        
        do {
            let imgs = try persistentContainer.viewContext.fetch(fetchRequest)
            if imgs.count > 0 {
                print("ProfileImageService_CoreData: Found imgs with uid -> \(uid)")
                return imgs
            } else {
                print("ProfileImageService_CoreData: Could not find imgs w uid: \(uid)")
                return nil
            }
        } catch {
            print("ProfileImageService_CoreData: Could not find imgs w uid: \(uid)")
            return nil
        }
    }
}

extension ProfileImageService_CoreData {
    
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
                print("ProfileImageService_CoreData: Found img with index -> \(index)")
                return imgs[0]
            } else {
                print("ProfileImageService_CoreData: Could not find img w uid: \(uid), and index: \(index)")
                return nil
            }
        } catch {
            print("ProfileImageService_CoreData: Could not find img w uid: \(uid), and index: \(index)")
            return nil
        }
    }
    
    private func deleteImage(img: ProfileImageCD) {
        persistentContainer.viewContext.delete(img)
        
        do {
            try persistentContainer.viewContext.save()
            print("ProfileImageService_CoreData: Successfully deleted img with index -> \(String(describing: img.index))")
        } catch {
            print("ProfileImageService_CoreData: Failed to save context")
        }
    }
    
    private func bundleProfileImage(uid: String, imgModel: ImageModel, imgCD: ProfileImageCD) {
        imgCD.uid = uid
        imgCD.index = String(imgModel.index)
        
        let data = imgModel.image.jpegData(compressionQuality: compressionQuality)!
        imgCD.img = data
    }
}
