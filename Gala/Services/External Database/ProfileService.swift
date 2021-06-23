//
//  ProfileService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ProfileServiceProtocol {
    func addProfileText(_ profile: ProfileModel) -> AnyPublisher<Void, Error>
    func addProfileImages(_ images: [ImageModel]) -> AnyPublisher<Void, Error>
    func getCurrentUserProfile() -> AnyPublisher<ProfileModel?, Error>
}

class ProfileService: ProfileServiceProtocol {
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    private let currentUID: String? = UserService.shared.currentUser?.uid
    
    func addProfileImages(_ images: [ImageModel]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }
        .eraseToAnyPublisher()
    }

    func addProfileText(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        
        var bio = ""
        var job = ""
        var school = ""
        
        if profile.bio != nil {
            bio = profile.bio!
        }
        
        if profile.job != nil {
            job = profile.job!
        }
        
        if profile.school != nil {
            school = profile.school!
        }
        
        return Future<Void, Error> { promise in
            self.db.collection("UserProfiles").document(self.currentUID!).setData([
                "name" : profile.name,
                "age" : Timestamp(date: profile.birthday),
                "city" : profile.city,
                "country" : profile.country,
                "bio" : bio,
                "gender" : profile.gender,
                "sexuality" : profile.sexuality,
                "job" : job,
                "school" : school,
                "id" : profile.userID
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    promise(.failure(err))
                } else {
                    print("Document successfully written!")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentUserProfile() -> AnyPublisher<ProfileModel?, Error> {
        Future<ProfileModel?, Error> { promise in
            let docRef = self.db.collection("UserProfiles").document(self.currentUID!)
            
            docRef.getDocument { (document, error) in
                let result = Result {
                    try document?.data(as: ProfileModel.self)
                }
                
                switch result {
                case .success(let profile):
                    if let profile = profile {
                        print("profile: \(profile)")
                        
                        let profile = ProfileModel(
                            name: profile.name,
                            birthday: profile.birthday,
                            city: profile.city,
                            country: profile.country,
                            userID: profile.userID,
                            bio: profile.bio,
                            gender: profile.gender,
                            sexuality: profile.sexuality,
                            job: profile.job,
                            school: profile.school
                        )
                        
                        promise(.success(profile))
                        
                    } else {
                        print("profile does not exist")
                    }
                    
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
