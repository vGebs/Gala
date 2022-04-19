//
//  ProfileService.swift
//  Gala
//
//  Created by Vaughn on 2022-04-04.
//

import Foundation
import Combine
import SwiftUI

protocol ProfileServiceProtocol {
    func createProfile(_ profile: ProfileModel) -> AnyPublisher<Void, Error>
    func getProfile(uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error>
    func getFullProfile(uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error>
    func updateCurrentUserProfile(uc: UserCore?, abt: UserAbout?, profImage: [ImageModel]?, imgs: [ImageModel]?, uid: String) -> AnyPublisher<Void, Error>
}

class ProfileService: ProfileServiceProtocol {
    
    var coreService: UserCoreService
    var aboutService: UserAboutService
    var imgService: ProfileImageService
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = ProfileService()
    
    private init() {
        self.coreService = UserCoreService.shared
        self.aboutService = UserAboutService.shared
        self.imgService = ProfileImageService.shared
    }
    
    func createProfile(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return createProfile_(profile)
    }
    
    func getProfile(uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
        return getProfile_(uid)
    }
    
    func getFullProfile(uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
        return getUserProfile_(uid)
    }
    
    func updateCurrentUserProfile(uc: UserCore?, abt: UserAbout?, profImage: [ImageModel]?, imgs: [ImageModel]?, uid: String) -> AnyPublisher<Void, Error> {
        return updateCurrentUserProfile_(uc, abt, profImage, imgs, uid)
    }
}

//MARK: - createProfile()
extension ProfileService {
    
    private func createProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        //Call profileText & addImages
        return Future<Void,Error> { [weak self] promise in
            Publishers.Zip4(
                self!.addUserCore(profile.userCore),
                self!.addUserAbout(profile.userAbout, uid: profile.userCore.userBasic.uid),
                self!.addImages(profile.images),
                RecentlyJoinedUserService.shared.addNewUser(core: profile.userCore)
            )
            .sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    print("ProfileService: Finished creating profile")
                    promise(.success(()))
                }
            } receiveValue: { _ in }
            .store(in: &self!.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private func addUserCore(_ userCore: UserCore) -> AnyPublisher<Void, Error> {
        return coreService.addNewUser(core: userCore)
    }
    
    private func addUserAbout(_ userAbout: UserAbout, uid: String) -> AnyPublisher<Void, Error>{
        return aboutService.addUserAbout(userAbout, uid: uid)
    }
    
    private func addImages(_ allImages: [ImageModel]) -> AnyPublisher<Void, Error>{
        return self.imgService.uploadProfileImages(uid: AuthService.shared.currentUser!.uid, imgs: allImages)
    }
}

extension ProfileService {
    private func getProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
        return Future<(UserCore?, UIImage?), Error> { [weak self] promise in
            Publishers.Zip(
                self!.coreService.getUserCore(uid: uid),
                self!.imgService.getProfileImage(uid: uid, index: "0")
            ).sink { completion in
                switch completion{
                case .failure(let e):
                    print("ProfileService: Failed to fetch UserCore and ProfileImg")
                    print("ProfileService-err: \(e)")
                case .finished:
                    print("ProfileService: Successfully fetched usercore and img")
                }
            } receiveValue: { uc, img in
                promise(.success((uc, img)))
            }
            .store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func getUserProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error>{
        
        return Future<(UserCore?, UserAbout?, [ImageModel]?), Error> { [weak self] promise in
            Publishers.Zip3(
                self!.coreService.getUserCore(uid: uid),
                self!.aboutService.getUserAbout(uid: uid),
                self!.getUserImages(uid: uid)
            ).sink { completion in
                switch completion {
                case .failure(let error):
                    print("ProfileService: getUserProfile_() failed: \(error.localizedDescription)")
                case .finished:
                    print("ProfileService-getUserProfile_(): got user profile")
                }
            } receiveValue: { core, about, imgs in
                promise(.success((core, about, imgs)))
            }
            .store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func getUserImages(uid: String) -> AnyPublisher<[ImageModel]?, Error> {
        return Future<[ImageModel]?, Error> { [weak self] promise in
            var profileImgs: [ImageModel]? = nil
            var imgsRecieved = 0
            var imgsNotFound = 0
            for i in 0..<7 {
                self!.imgService.getProfileImage(uid: uid, index: String(i))
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion{
                        case let .failure(error):
                            //promise(.failure(error))
                            print("ProfileService: Failed to fetch img with index: \(i)")
                            print("ProfileService: \(error.localizedDescription)")
                        case .finished:
                            print("ProfileService: Finished getting img with index: \(i)")
                        }
                    } receiveValue: { img in
                        if let img = img {
                            print("image coming from firebase: \(img)")
                            let image = ImageModel(image: img, index: i)
                            if profileImgs == nil {
                                let tempArr = [image]
                                profileImgs = tempArr
                                imgsRecieved += 1
                                //print("img received: \(imgsRecieved)")
                            } else {
                                profileImgs?.append(image)
                                imgsRecieved += 1
                                //print("img received: \(imgsRecieved)")
                            }
                            //print("Describing profile images: \(String(describing: profileImgs))")
                        } else {
                            print("no image found")
                            imgsNotFound += 1
                            print("img not received: \(imgsNotFound)")
                        }
                        
                        if (imgsRecieved + imgsNotFound) == 7 {
                            if let _ = profileImgs {
                                profileImgs!.sort { (i1, i2) -> Bool in
                                    return i1.index < i2.index
                                }
                            }
                            
                            promise(.success(profileImgs))
                        }
                    }
                    .store(in: &self!.cancellables)
            }
        }.eraseToAnyPublisher()
    }
}

extension ProfileService {
    private func updateCurrentUserProfile_(_ uc: UserCore?, _ abt: UserAbout?, _ profImage: [ImageModel]?, _ imgs: [ImageModel]?, _ uid: String) -> AnyPublisher<Void, Error> {

        //we're calling this function from ProfileViewModel
        
        return Future<Void, Error> { [weak self] promise in
            Publishers.Zip4(
                self!.handleUpdateUserCore(uc: uc),
                self!.handleUpdateUserAbout(abt: abt, uid: uid),
                self!.handleUpdateProfilePic(profileImage: profImage),
                self!.handleUpdateImgs(images: imgs)
            ).sink { completion in
                switch completion {
                case .failure(let e):
                    print("ProfileService: Failed to update profile")
                    promise(.failure(e))
                case .finished:
                    print("ProfileService: Finished updating profile")
                    promise(.success(()))
                }
            } receiveValue: { (_, _, _, _) in }
            .store(in: &self!.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func handleUpdateUserCore(uc: UserCore?) -> AnyPublisher<Void, Error> {
        
        return Future<Void, Error> { [weak self] promise in
            if let u = uc {
                self!.coreService.updateUser(userCore: u)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileService: Failed to update UserCore")
                            promise(.failure(e))
                        case .finished:
                            print("ProfileService: Finished updating UserCore")
                            promise(.success(()))
                        }
                    } receiveValue: { _ in }
                    .store(in: &self!.cancellables)
            } else {
                print("ProfileService: No UserCore to update")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
        
        //Refetch RecentlyJoined and refetch vibe stories
    }
    
    private func handleUpdateUserAbout(abt: UserAbout?, uid: String?) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            if let a = abt, let uid = uid {
                self!.aboutService.updateUserAbout(a, uid: uid)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileService: Failed to update UserAbout")
                            promise(.failure(e))
                        case .finished:
                            print("ProfileService: Finished updating UserAbout")
                            promise(.success(()))
                        }
                    } receiveValue: { _ in }
                    .store(in: &self!.cancellables)
            } else {
                print("ProfileService: no UserAbout to update")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    private func handleUpdateImgs(images: [ImageModel]?) -> AnyPublisher<Void, Error> {
        //When we update our imgs, we need to:
        //  1. Push all images with their new indexes
        //  2. If we do not have exactly 6 imgs in array, we need to delete the higher indexes
        
        return Future<Void, Error> { [weak self] promise in
            if let imgs = images {
                let maxImgCount = 6
                let currentImgCount = imgs.count
                
                if maxImgCount - currentImgCount == 0 {
                    //Overwrite all images
                    for i in 0..<imgs.count {
                        self!.imgService.uploadProfileImage(uid: AuthService.shared.currentUser!.uid, img: imgs[i])
                            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                            .receive(on: DispatchQueue.main)
                            .sink { completion in
                                switch completion {
                                case .failure(let e):
                                    print("ProfileService: Failed to update img w index -> \(imgs[i].index)")
                                    print("ProfileService-err: \(e.localizedDescription)")
                                case .finished:
                                    print("ProfileService: Finished updating img w index -> \(imgs[i].index)")
                                }
                            } receiveValue: { _ in
                                if i == imgs.count - 1 {
                                    promise(.success(()))
                                }
                            }
                            .store(in: &self!.cancellables)
                    }
                } else {
                    //We do not have full images
                    //Overwrite the images we already have
                    for i in 0..<imgs.count {
                        self!.imgService.uploadProfileImage(uid: AuthService.shared.currentUser!.uid, img: imgs[i])
                            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                            .receive(on: DispatchQueue.main)
                            .sink { completion in
                                switch completion {
                                case .failure(let e):
                                    print("ProfileService: Failed to update img w index -> \(imgs[i].index)")
                                    print("ProfileService-err: \(e.localizedDescription)")
                                case .finished:
                                    print("ProfileService: Finished updating img w index -> \(imgs[i].index)")
                                }
                            } receiveValue: { _ in }
                            .store(in: &self!.cancellables)
                    }
                    
                    //We now need to delete the remaining images
                    let loopTimes = maxImgCount - currentImgCount
                    
                    for i in 0..<loopTimes {
                        self!.imgService.deleteProfileImage(uid: AuthService.shared.currentUser!.uid, index: "\(maxImgCount - i)")
                            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                            .receive(on: DispatchQueue.main)
                            .sink { completion in
                                switch completion {
                                case .failure(let e):
                                    print("ProfileService: Failed to delete img w index -> \(maxImgCount - i)")
                                    print("ProfileService-err: \(e.localizedDescription)")
                                case .finished:
                                    print("ProfileService: Finished delete img w index -> \(maxImgCount - i)")
                                }
                            } receiveValue: { _ in
                                if i == loopTimes - 1 {
                                    promise(.success(()))
                                }
                            }
                            .store(in: &self!.cancellables)
                    }
                }
            } else {
                print("ProfileService: No imgs to update")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    private func handleUpdateProfilePic(profileImage: [ImageModel]?) -> AnyPublisher<Void, Error>{
        //When we update the profile pic, we need to:
        //  1. Check to see if there is an image in profilePics
        //      a. if there is an image, we overwrite the img in place 1
        //      b. if there is not an image, we delete the current 0th place img
        
        return Future<Void, Error> { [weak self] promise in
            
            if let profileImage = profileImage {
                if profileImage.count == 0 {
                    self!.imgService.deleteProfileImage(uid: AuthService.shared.currentUser!.uid, index: "0")
                        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .failure(let e):
                                print("ProfileService: Failed to delete profile img")
                                print("ProfileService-err: \(e)")
                                promise(.failure(e))
                            case .finished:
                                print("ProfileService: Finished deleting Profile pic")
                                promise(.success(()))
                            }
                        } receiveValue: { _ in }
                        .store(in: &self!.cancellables)
                } else {
                    self!.imgService.uploadProfileImage(uid: AuthService.shared.currentUser!.uid, img: profileImage[0])
                        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .failure(let e):
                                print("ProfileService: Failed to update profile img")
                                print("ProfileService-err: \(e)")
                                promise(.failure(e))
                            case .finished:
                                print("ProfileService: Finished update Profile pic")
                                promise(.success(()))
                            }
                        } receiveValue: { _ in }
                        .store(in: &self!.cancellables)
                }
            } else {
                print("ProfileService: No profile img to update")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}
