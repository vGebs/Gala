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

class ProfileService_CoreData: ObservableObject, ProfileServiceProtocol {
    
    static let shared = ProfileService_CoreData()
    
    private init() {  }
    
    func createProfile(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return createProfile_(profile)
    }
    
    func getProfile(uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
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
extension ProfileService_CoreData {
    private func createProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}

// MARK: - getProfile()
extension ProfileService_CoreData {
    func getProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UIImage?), Error> {
        return Future<(UserCore?, UIImage?), Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}

// MARK: - getFullProfile()
extension ProfileService_CoreData {
    func getFullProfile_(_ uid: String) -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
        return Future<(UserCore?, UserAbout?, [ImageModel]?), Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}

// MARK: - updateCurrentUserProfile()
extension ProfileService_CoreData {
    func updateCurrentUserProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
