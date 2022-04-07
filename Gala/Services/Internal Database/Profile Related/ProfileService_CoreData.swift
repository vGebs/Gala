//
//  ProfileService_CoreData.swift
//  Gala
//
//  Created by Vaughn on 2022-04-02.
//

import Foundation
import Combine
import SwiftUI
import CoreData
//
//class ProfileService_CoreData: ObservableObject, ProfileServiceProtocol {
//
//    static let shared = ProfileService_CoreData()
//
//    let userCoreService = UserCorePersistence()
//    let userAboutService = UserAboutPersistence()
//    let profileImageService = ProfileImagePersistence()
//
//    private init() {  }
//
//    private var cancellables: [AnyCancellable] = []
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
//        return getFullProfile_(uid)
//    }
//
//    func updateCurrentUserProfile(uc: UserCore?, abt: UserAbout?, imgs: [ImageModel]?) -> AnyPublisher<Void, Error> {
//        return updateCurrentUserProfile_(uc, abt, imgs)
//    }
//}
//
//// MARK: - createProfile()
//extension ProfileService_CoreData {
//    private func createProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
//        return Future<Void, Error> { [weak self] promise in
//            Publishers.Zip3(
//                self!.addUserCore(profile.userCore),
//                self!.addUserAbout(profile.userAbout),
//                self!.addProfileImages(profile.images)
//            )
//            .sink { completion in
//                switch completion {
//                case .failure(let e):
//                    print("ProfileService_CoreData: Failed to push profile")
//                    promise(.failure(e))
//                case .finished:
//                    print("ProfileService_CoreData: Finished pushing profile")
//                    promise(.success(()))
//                }
//            } receiveValue: { _, _ , _ in }
//            .store(in: &self!.cancellables)
//        }.eraseToAnyPublisher()
//    }
//
//
//    private func addUserCore(_ uc: UserCore) -> AnyPublisher<Void, Error> {
//        return userCoreService.addUser(user: uc)
//    }
//
//    private func addUserAbout(_ abt: UserAbout) -> AnyPublisher<Void, Error> {
//        return userAboutService.addUser(user: abt)
//    }
//
//    private func addProfileImages(_ imgs: [ImageModel]) -> AnyPublisher<Void, Error> {
//        return Future<Void, Error> { [weak self] promise in
//            if imgs.count == 0 {
//                promise(.success(()))
//            } else {
//                for i in 0..<imgs.count {
//                    self!.profileImageService.addImg(img: imgs[i])
//                        .sink { completion in
//                            switch completion {
//                            case .failure(let error):
//                                print("ImageService-uploadProfileImages index: \(String(i)) failed: \(error.localizedDescription)")
//                                if i == (imgs.count - 1){
//                                    promise(.success(()))
//                                }
//                            case .finished:
//                                print("ImageService-uploadProfile: image i=\(String(i)) successfully added")
//                                if i == (imgs.count - 1){
//                                    promise(.success(()))
//                                }
//                            }
//                        } receiveValue: { _ in }
//                        .store(in: &self!.cancellables)
//                }
//            }
//        }.eraseToAnyPublisher()
//    }
//}
//
//// MARK: - getProfile()
//extension ProfileService_CoreData {
//    func getProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
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
//}
//
//// MARK: - getFullProfile()
//extension ProfileService_CoreData {
//    func getFullProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
//        return Future<(UserCore?, UserAbout?, [ImageModel]?), Error> { promise in
//
//        }.eraseToAnyPublisher()
//    }
//}
//
//// MARK: - updateCurrentUserProfile()
//extension ProfileService_CoreData {
//    private func updateCurrentUserProfile_(_ uc: UserCore?, _ abt: UserAbout?, _ imgs: [ImageModel]?) -> AnyPublisher<Void, Error> {
//        return Future<Void, Error> { promise in
//
//        }.eraseToAnyPublisher()
//    }
//}
