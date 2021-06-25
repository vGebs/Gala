//
//  ProfileTextService.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import Combine
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ProfileTextServiceProtocol {
    func addProfileText(_ profile: ProfileModel) -> AnyPublisher<Void, Error>
    func getCurrentUserProfileText() -> AnyPublisher<ProfileModel?, Error>
}

class ProfileTextService: ProfileTextServiceProtocol {
    private let db = Firestore.firestore()
    private let currentUID: String? = UserService.shared.currentUser?.uid
    
    static let shared = ProfileTextService()
    
    private init() {}

    func addProfileText(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection("UserProfiles").document(self.currentUID!).setData([
                "name" : profile.name,
                "age" : Timestamp(date: profile.birthday),
                "city" : profile.city,
                "country" : profile.country,
                "bio" : profile.bio!,
                "gender" : profile.gender,
                "sexuality" : profile.sexuality,
                "job" : profile.job!,
                "school" : profile.school!,
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
    
    func getCurrentUserProfileText() -> AnyPublisher<ProfileModel?, Error> {
        Future<ProfileModel?, Error> { promise in
            let docRef = self.db.collection("UserProfiles").document(self.currentUID!)
            
            docRef.getDocument { (document, error) in
                let result = Result {
                    try document?.data(as: ProfileModel.self)
                }
                
                switch result {
                case .success(let profile):
                    if let profile = profile {
                        
                        let profileFinal = ProfileModel(
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
                        
                        print("profile: \(profileFinal)")

                        promise(.success(profileFinal))
                        
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
