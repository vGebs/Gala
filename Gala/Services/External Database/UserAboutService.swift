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

protocol UserAboutServiceProtocol {
    func addUserAbout(_ profile: ProfileModel) -> AnyPublisher<Void, Error>
    func getCurrentUserAbout() -> AnyPublisher<UserAbout?, Error>
}

class UserAboutService: UserAboutServiceProtocol {
    private let db = Firestore.firestore()
    private let currentUID: String? = UserService.shared.currentUser?.uid
    
    static let shared = UserAboutService()
    
    private init() {}

    func addUserAbout(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection("UserAbout").document(self.currentUID!).setData([
                "bio" : profile.bio!,
                "job" : profile.job!,
                "school" : profile.school!,
            ]) { err in
                if let err = err {
                    print("UserAboutService: Error writing document: \(err)")
                    promise(.failure(err))
                } else {
                    print("UserAboutService: Document successfully written!")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentUserAbout() -> AnyPublisher<UserAbout?, Error> {
        Future<UserAbout?, Error> { promise in
            let docRef = self.db.collection("UserAbout").document(self.currentUID!)
            
            docRef.getDocument { (document, error) in
                let result = Result {
                    try document?.data(as: UserAbout.self)
                }
                
                switch result {
                case .success(let abt):
                    if let profile = abt {
                        print("profile: \(profile)")
                        
                        promise(.success(profile))
                    } else {
                        promise(.success(nil))
                        print("UserAboutService: UserAbout profile does not exist")
                    }
                    
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}