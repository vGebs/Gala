//
//  ProfileTextService.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import Combine

protocol UserAboutServiceProtocol {
    associatedtype void
    associatedtype userAbout
    
    func addUserAbout(_ userAbout: UserAbout, uid: String) -> void
    func getUserAbout(uid: String) -> userAbout
    func updateUserAbout(_ userAbout: UserAbout, uid: String) -> void
}

class UserAboutService: UserAboutServiceProtocol {
    
    typealias void = AnyPublisher<Void, Error>
    typealias userAbout = AnyPublisher<UserAbout?, Error>
    
    static let shared = UserAboutService()
    
    private var firebase: UserAboutService_Firebase
    private var coreData: UserAboutService_CoreData
    
    private var subs: [AnyCancellable] = []
    
    private init() {
        firebase = UserAboutService_Firebase.shared
        coreData = UserAboutService_CoreData.shared
    }
    
    func addUserAbout(_ userAbout: UserAbout, uid: String) -> void {
        return Future<Void, Error> { [weak self] promise in
            //we want to add the userCore to
            self?.firebase.addUserAbout(userAbout, uid: uid)
                .map{ _ in
                    self!.coreData.addUserAbout(userAbout, uid: uid)
                }
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("UserAboutService: Failed to addNewUserAbout")
                        print("UserAboutService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("UserAboutService: Finished addNewUserAbout")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }.eraseToAnyPublisher()
    }
    
    func updateUserAbout(_ userAbout: UserAbout, uid: String) -> void {
        return Future<Void, Error> { [weak self] promise in
            self!.firebase.updateUserAbout(userAbout, uid: uid)
                .map{ _ in
                    self!.coreData.updateUserAbout(userAbout, uid: uid)
                }
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("UserCoreService: Failed to update UserAbout w/ id -> \(uid)")
                        print("UserAboutService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("UserAboutService: Finished updating UserAbout w/ id -> \(uid)")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }.eraseToAnyPublisher()
    }
    
    func getUserAbout(uid: String) -> userAbout {
        return Future<UserAbout?, Error> { [weak self] promise in
            if let userAbout = self!.coreData.getUserAbout(uid: uid) {
                promise(.success(userAbout))
            } else {
                self!.firebase.getUserAbout(uid: uid)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("UserCoreService: Failed to get userCore from firebase")
                            print("UserCoreService-err: \(e)")
                            promise(.success(nil))
                        case .finished:
                            print("UserCoreService: Finished ")
                        }
                    } receiveValue: { [weak self] ua in
                        if let ua = ua {
                            if uid == AuthService.shared.currentUser!.uid {
                                self!.coreData.addUserAbout(ua, uid: uid)
                            }
                        }
                        promise(.success(ua))
                    }
                    .store(in: &self!.subs)
            }
        }.eraseToAnyPublisher()
    }
}
