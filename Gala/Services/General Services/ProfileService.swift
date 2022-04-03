//
//  ProfileService.swift
//  Gala
//
//  Created by Vaughn on 2022-04-02.
//

import Foundation
import Combine
import SwiftUI


//This class combines the ProfileService_CoreData & ProfileService_Firebase
class ProfileService: ObservableObject, ProfileServiceProtocol {
    
    static let shared = ProfileService()
    
    private init() { }
    
    func createProfile(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        //when we create a profile, we want to first push it to the database (FireStore)
        //Once we receive a successful completion, we push to Core Data.
        //The reason we wait for the success completion is because we want the data in Core Data to be consistent with the external database
        return createProfile_(profile)
    }
    
    func getProfile(uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
        //When fetching a profile, we want to fetch core data first
        //If the result is there, we return it,
        //If there is no value, we fetch firestore
        return getProfile_(uid)
    }
    
    func getFullProfile(uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
        return getFullProfile_(uid)
    }
    
    func updateCurrentUserProfile(profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return updateCurrentUserProfile_(profile)
    }
}


// MARK: - createProfile()
extension ProfileService {
    private func createProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return ProfileService_Firebase.shared.createProfile(profile)
            .flatMap { _ -> AnyPublisher<Void, Error> in
                ProfileService_CoreData.shared.createProfile(profile)
            }.eraseToAnyPublisher()
    }
}

// MARK: - getProfile()
extension ProfileService {
    func getProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
        return Future<(UserCore?, UIImage?), Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}

// MARK: - getFullProfile()
extension ProfileService {
    func getFullProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
        return Future<(UserCore?, UserAbout?, [ImageModel]?), Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}

// MARK: - updateCurrentUserProfile()
extension ProfileService {
    func updateCurrentUserProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
