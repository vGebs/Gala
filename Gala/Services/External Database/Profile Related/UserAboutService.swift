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
    func addUserAbout(_ userAbout: UserAbout, uid: String) -> AnyPublisher<Void, Error>
    func getUserAbout(uid: String) -> AnyPublisher<UserAbout?, Error>
    func updateUserAbout(_ userAbout: UserAbout, uid: String) -> AnyPublisher<Void, Error>
}

class UserAboutService: UserAboutServiceProtocol {
    
    private let db = Firestore.firestore()
    
    static let shared = UserAboutService()
    
    private init() {}

    func addUserAbout(_ userAbout: UserAbout, uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            if userAbout.bio == "" && userAbout.job == "" && userAbout.school == "" {
                promise(.success(()))
            } else {
                self.db.collection("UserAbout").document(AuthService.shared.currentUser!.uid).setData([
                    "bio" : userAbout.bio!,
                    "job" : userAbout.job!,
                    "school" : userAbout.school!
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
        }
        .eraseToAnyPublisher()
    }
    
    func getUserAbout(uid: String) -> AnyPublisher<UserAbout?, Error> {
        Future<UserAbout?, Error> { promise in
            let docRef = self.db.collection("UserAbout").document(uid)
            
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
    
    func updateUserAbout(_ userAbout: UserAbout, uid: String) -> AnyPublisher<Void, Error> {
        return addUserAbout(userAbout, uid: uid)
    }
}
