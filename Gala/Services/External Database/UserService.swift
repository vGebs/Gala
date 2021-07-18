//
//  UserService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import FirebaseAuth

protocol UserServiceProtocol {
    var currentUser: User? { get }
    func createAcountWithEmail(email: String, password: String) -> AnyPublisher<Void, Error>
    func signInWithEmail(email: String, password: String) -> AnyPublisher<Void, Error>
    func logout() -> AnyPublisher<Void, Error>
    func observeAuthChanges() -> AnyPublisher<User?, Never>
}

class UserService: UserServiceProtocol{

    var currentUser: User?
    
    static let shared = UserService()
    private init() {  }
    
    func createAcountWithEmail(email: String, password: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error { return promise(.failure(error)) }
                self.currentUser = authResult?.user
                return promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func signInWithEmail(email: String, password: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error { return promise(.failure(error)) }
                self.currentUser = authResult?.user
                return promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                self.currentUser = nil
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observeAuthChanges() -> AnyPublisher<User?, Never> {
        Publishers.AuthPublisher().eraseToAnyPublisher()
    }
}
