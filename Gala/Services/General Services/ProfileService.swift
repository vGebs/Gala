//
//  ProfileService.swift
//  Gala
//
//  Created by Vaughn on 2022-04-02.
//

import Foundation
import Combine
import SwiftUI

protocol ProfileServiceProtocol {
    func createProfile(_ profile: ProfileModel) -> AnyPublisher<Void, Error>
    func getProfile(uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error>
    func getFullProfile(uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error>
    func updateCurrentUserProfile(uc: UserCore?, abt: UserAbout?, profImage: [ImageModel]?, imgs: [ImageModel]?) -> AnyPublisher<Void, Error>
}

//This class combines the ProfileService_CoreData & ProfileService_Firebase
class ProfileService: ObservableObject, ProfileServiceProtocol {
    
    static let shared = ProfileService()
    
    let firebase: ProfileServiceProtocol
    let coreData: ProfileServiceProtocol
    
    private init() {
        firebase = ProfileServiceWrapper(
            coreService: UserCoreService.shared,
            aboutService: UserAboutService.shared,
            imgService: ProfileImageService.shared
        )
        
        coreData = ProfileServiceWrapper(
            coreService: UserCorePersistence.shared,
            aboutService: UserAboutPersistence.shared,
            imgService: ProfileImagePersistence.shared
        )
    }
    
    func createProfile(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        //when we create a profile, we want to first push it to the database (FireStore)
        //Once we receive a successful completion, we push to Core Data.
        //The reason we wait for the success completion is because we want Core Data to be consistent with firestore
        return createProfile_(profile)
    }
    
    func getProfile(uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
        //When fetching a profile, we want to fetch core data first
        //If the result is there, we return it,
        //If there is no value, we fetch firestore
        return getProfile_(uid)
    }
    
    func getFullProfile(uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
        //When fetching a profile, we want to fetch core data first
        //If the result is there, we return it,
        //If there is no value, we fetch firestore
        return getFullProfile_(uid)
    }
    
    func updateCurrentUserProfile(uc: UserCore?, abt: UserAbout?, profImage: [ImageModel]?, imgs: [ImageModel]?) -> AnyPublisher<Void, Error> {
        return updateCurrentUserProfile_(uc, abt, profImage, imgs)
    }
}


// MARK: - createProfile()
extension ProfileService {
    private func createProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return firebase.createProfile(profile)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                self!.coreData.createProfile(profile)
            }.eraseToAnyPublisher()
    }
}

// MARK: - getProfile()
extension ProfileService {
    func getProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
        return firebase.getProfile(uid: uid)
    }
}

// MARK: - getFullProfile()
extension ProfileService {
    func getFullProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
        return firebase.getFullProfile(uid: uid)
    }
}

// MARK: - updateCurrentUserProfile()
extension ProfileService {
    private func updateCurrentUserProfile_(_ uc: UserCore?, _ abt: UserAbout?, _ profImage: [ImageModel]?, _ imgs: [ImageModel]?) -> AnyPublisher<Void, Error> {
        return firebase.updateCurrentUserProfile(uc: uc, abt: abt, profImage: profImage, imgs: imgs)
    }
}
