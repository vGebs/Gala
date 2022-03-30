//
//  UserService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import FirebaseAuth

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    
    func createAcountWithEmail(email: String, password: String) -> AnyPublisher<Void, Error>
    func signIn(email: String, password: String) -> AnyPublisher<UserCore?, Error>
    func logout() -> AnyPublisher<Void, Error>
    func observeAuthChanges() -> AnyPublisher<User?, Never>
}

class AuthService: AuthServiceProtocol{

    var currentUser: User? = Auth.auth().currentUser
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = AuthService()
    private init() { }
    
    func createAcountWithEmail(email: String, password: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error { return promise(.failure(error)) }
                self?.currentUser = authResult?.user
                return promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) -> AnyPublisher<UserCore?, Error> {
        self.signInWithEmail(email, password)
            .flatMap{ user in
                UserCoreService.shared.getUserCore(uid: user.uid)
            }
            .eraseToAnyPublisher()
    }
    
    private func signInWithEmail(_ email: String, _ password: String) -> AnyPublisher<User, Error> {
        Future<User, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error { return promise(.failure(error)) }
                if let auth = authResult {
                    self?.currentUser = auth.user
                    promise(.success(auth.user))
                }
            }
        }.eraseToAnyPublisher()
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

extension AuthService {
    private enum UserCoreServiceError: Error {
        case emptyUserCore
    }
}
