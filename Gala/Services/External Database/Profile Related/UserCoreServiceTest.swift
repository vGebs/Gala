//
//  UserCoreServiceTest.swift
//  Gala
//
//  Created by Vaughn on 2022-04-13.
//

import Combine

class UserCoreServiceTest: UserCoreServiceProtocol {
    
    static let shared = UserCoreServiceTest()
    
    private init() {}
    
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error> {
        //In this function we want to add a new user
        //To add a new user we want to first call firebase
        // If we get a successful completion, we then push to core data
        // if we do not get a successful completion, we should retry the operation
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
    
    func getUserCore(uid: String?) -> AnyPublisher<UserCore?, Error> {
        //In this function we want to fetch core data
        return Future<UserCore?, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
    
    func updateUser(userCore: UserCore) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}

protocol P {
    associatedtype T
    func doSomethhing() -> T
}

class PP: P {
    func doSomethhing() -> AnyPublisher<Int, Error> {
        return Future<Int, Error> { promise in
            promise(.success(7))
        }.eraseToAnyPublisher()
    }
}

class P_p: P {
    func doSomethhing() -> Int {
        return 22
    }
}

class Caller {
    var pp = PP()
    var p_p = P_p()
    
    private var subs: [AnyCancellable] = []
    
    init() { }
    
    func pushProfile() -> AnyPublisher<Void, Error>{
        return Future<Void, Error> { [weak self] promise in
            self!.pp.doSomethhing() //Push to firebase
                .map{ [weak self] num in
                    self!.p_p.doSomethhing() //Push to coreData
                }
                .sink { _ in
                    print("Finished pushing profile to firebase and coredata")
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }.eraseToAnyPublisher()
    }
    
    func getProfile() {
        
    }
    
    func getProfile_() -> AnyPublisher<Int, Error> {
        return Future<Int, Error> { [weak self] promise in
            let num = self!.p_p.doSomethhing()
            
            if num != nil{
                print("Got profile from core data")
                promise(.success(num))
            } else if num == nil {
                self!.pp.doSomethhing()
                    .sink { completion in
                        print("Done")
                    } receiveValue: { [weak self] num in
                        print("Got profile from firebase")
                        print("now we have to push it to core data")
                        
                        self!.p_p.doSomethhing()
                        
                        promise(.success(num))
                    }
                    .store(in: &self!.subs)
            }
        }.eraseToAnyPublisher()
    }
}
