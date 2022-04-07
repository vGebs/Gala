//
//  ProfileService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

//Should i query firebase directly?: Link https://medium.com/firebase-developers/should-i-query-my-firebase-database-directly-or-use-cloud-functions-fbb3cd14118c

import Combine
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

//
////MARK: ProfileService
////Objective:
////      To push and pull full profiles (profile text & all Profile Images) from firestore
////
//class ProfileService_Firebase: ProfileServiceProtocol {
//    
//    private let coreService: UserCoreServiceProtocol
//    private let aboutService: UserAboutServiceProtocol
//    private let imgService: ProfileImageServiceProtocol
//    private let recentService: RecentlyJoinedUserServiceProtocol
//        
//    private var cancellables: [AnyCancellable] = []
//    
//    static let shared = ProfileService_Firebase()
//    private init() {
//        coreService = UserCoreService.shared
//        aboutService = UserAboutService.shared
//        imgService = ProfileImageService.shared
//        recentService = RecentlyJoinedUserService.shared
//    }
//    
//    func createProfile(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
//        return createProfile_(profile)
//    }
//    
//    func getProfile(uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
//        return getProfile_(uid)
//    }
//    
//    func getFullProfile(uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
//        return getUserProfile_(uid)
//    }
//    
//    func updateCurrentUserProfile(uc: UserCore?, abt: UserAbout?, imgs: [ImageModel]?) -> AnyPublisher<Void, Error> {
//        return updateCurrentUserProfile_(uc, abt, imgs)
//    }
//}
//
//
////MARK: - createProfile()
//extension ProfileService_Firebase {
//    
//    private func createProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
//        //Call profileText & addImages
//        return Future<Void,Error> { [weak self] promise in
//            Publishers.Zip4(
//                self!.addUserCore(profile.userCore),
//                self!.addUserAbout(profile.userAbout),
//                self!.addRecent(profile.userCore),
//                self!.addImages(profile.images)
//            )
//            .sink { completion in
//                switch completion {
//                case .failure(let error):
//                    promise(.failure(error))
//                case .finished:
//                    print("ProfileService: Finished creating profile")
//                    promise(.success(()))
//                }
//            } receiveValue: { _ in }
//            .store(in: &self!.cancellables)
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    private func addUserCore(_ userCore: UserCore) -> AnyPublisher<Void, Error> {
//        return coreService.addNewUser(core: userCore)
//    }
//    
//    private func addUserAbout(_ userAbout: UserAbout) -> AnyPublisher<Void, Error>{
//        return aboutService.addUserAbout(userAbout)
//    }
//    
//    private func addRecent(_ userCore: UserCore) -> AnyPublisher<Void, Error> {
//        return recentService.addNewUser(core: userCore)
//    }
//    
//    private func addImages(_ allImages: [ImageModel]) -> AnyPublisher<Void, Error>{
//        return self.imgService.uploadProfileImages(imgs: allImages)
//    }
//}
//
//
////MARK: - getUserProfile()
//extension ProfileService_Firebase {
//    
//    private func getProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
//        return Future<(UserCore?, UIImage?), Error> { [weak self] promise in
//            Publishers.Zip(
//                UserCoreService.shared.getUserCore(uid: uid),
//                ProfileImageService.shared.getProfileImage(id: uid, index: "0")
//            ).sink { completion in
//                switch completion{
//                case .failure(let e):
//                    print("ProfileService: Failed to fetch UserCore and ProfileImg")
//                    print("ProfileService-err: \(e)")
//                case .finished:
//                    print("ProfileService: Successfully fetched usercore and img")
//                }
//            } receiveValue: { uc, img in
//                promise(.success((uc, img)))
//            }
//            .store(in: &self!.cancellables)
//        }.eraseToAnyPublisher()
//    }
//    
//    private func getUserProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error>{
//        
//        return Future<(UserCore?, UserAbout?, [ImageModel]?), Error> { [weak self] promise in
//            Publishers.Zip3(
//                self!.coreService.getUserCore(uid: uid),
//                self!.aboutService.getUserAbout(uid: uid),
//                self!.getUserImages(uid: uid)
//            ).sink { completion in
//                switch completion {
//                case .failure(let error):
//                    print("ProfileService: getUserProfile_() failed: \(error.localizedDescription)")
//                case .finished:
//                    print("ProfileService-getUserProfile_(): got user profile")
//                }
//            } receiveValue: { core, about, imgs in
//                promise(.success((core, about, imgs)))
//            }
//            .store(in: &self!.cancellables)
//        }.eraseToAnyPublisher()
//    }
//    
//    //Because images are not coming back in order, what we can do is return an object with the index as well as the img. this can be done inside the 'ProfileImageService.shared.getProfileImage(id: uid, index: String(i))' function
//    private func getUserImages(uid: String) -> AnyPublisher<[ImageModel]?, Error> {
//        return Future<[ImageModel]?, Error> { promise in
//            var profileImgs: [ImageModel]? = nil
//            var imgsRecieved = 0
//            var imgsNotFound = 0
//            for i in 0..<7 {
//                ProfileImageService.shared.getProfileImage(id: uid, index: String(i))
//                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
//                    .sink { completion in
//                        switch completion{
//                        case let .failure(error):
//                            //promise(.failure(error))
//                            print("ProfileService non lethal error: \(error.localizedDescription)")
//                        case .finished:
//                            print("getting images from firebase: ProfileService")
//                        }
//                    } receiveValue: { img in
//                        if let img = img {
//                            print("image coming from firebase: \(img)")
//                            let image = ImageModel(image: img, index: i)
//                            if profileImgs == nil {
//                                let tempArr = [image]
//                                profileImgs = tempArr
//                                imgsRecieved += 1
//                                //print("img received: \(imgsRecieved)")
//                            } else {
//                                profileImgs?.append(image)
//                                imgsRecieved += 1
//                                //print("img received: \(imgsRecieved)")
//                            }
//                            //print("Describing profile images: \(String(describing: profileImgs))")
//                        } else {
//                            print("no image found")
//                            imgsNotFound += 1
//                            print("img not received: \(imgsNotFound)")
//                        }
//                        
//                        if (imgsRecieved + imgsNotFound) == 7 {
//                            if let _ = profileImgs {
//                                profileImgs!.sort { (i1, i2) -> Bool in
//                                    return i1.index < i2.index
//                                }
//                            }
//                            
//                            promise(.success(profileImgs))
//                        }
//                    }
//                    .store(in: &self.cancellables)
//            }
//        }.eraseToAnyPublisher()
//    }
//}
//
////MARK: - updateCurrentUserProfile()
//
//extension ProfileService_Firebase {
//    private func updateCurrentUserProfile_(_ uc: UserCore?, _ abt: UserAbout?, _ imgs: [ImageModel]?) -> AnyPublisher<Void, Error> {
//        return Future<Void, Error> { promise in
//            
//        }.eraseToAnyPublisher()
//    }
//}
