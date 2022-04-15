//
//  RecentlyJoinedUserService.swift
//  Gala
//
//  Created by Vaughn on 2021-07-08.
//

import Combine
import CoreLocation
import GeoFire
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol UserCoreServiceProtocol {
    associatedtype void
    associatedtype userCore
    
    func addNewUser(core: UserCore) -> void
    func getUserCore(uid: String?) -> userCore
    func updateUser(userCore: UserCore) -> void
}

class UserCoreService: UserCoreServiceProtocol {
    
    private let db = Firestore.firestore()
    
    typealias void = AnyPublisher<Void, Error>
    typealias userCore = AnyPublisher<UserCore?, Error>
    
    @Published var currentUserCore: UserCore?
    
    private var subs: [AnyCancellable] = []
    
    private var firebase: UserCoreService_Firebase
    private var coreData: UserCoreService_CoreData
    
    static let shared = UserCoreService()
    
    private init() {
        firebase = UserCoreService_Firebase.shared
        coreData = UserCoreService_CoreData.shared
    }
    
    func addNewUser(core: UserCore) -> void {
        if AuthService.shared.currentUser!.uid == core.userBasic.uid {
            currentUserCore = core
        }
        
        return Future<Void, Error> { [weak self] promise in
            self!.firebase.addNewUser(core: core)
                .map{ _ in
                    self!.coreData.addNewUser(core: core)
                }
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("UserCoreService: Failed to addNewUser")
                        print("UserCoreService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("UserCoreService: Finished addNewUser")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }.eraseToAnyPublisher()
    }
    
    func getUserCore(uid: String?) -> userCore {
        return Future<UserCore?, Error> { [weak self] promise in
            if let uid = uid {
                if let userCore = self!.coreData.getUserCore(uid: uid) {
                    if userCore.userBasic.uid == AuthService.shared.currentUser!.uid {
                        print("lat: \(userCore.searchRadiusComponents.coordinate.lat)")
                        print("lng: \(userCore.searchRadiusComponents.coordinate.lng)")
                        self!.currentUserCore = userCore
                    }
                    promise(.success(userCore))
                } else {
                    self!.firebase.getUserCore(uid: uid)
                        .sink { completion in
                            switch completion {
                            case .failure(let e):
                                print("UserCoreService: Failed to get userCore from firebase")
                                print("UserCoreService-err: \(e)")
                                promise(.success(nil))
                            case .finished:
                                print("UserCoreService: Finished getting UserCore")
                            }
                        } receiveValue: { [weak self] uc in
                            if let uc = uc {
                                if uc.userBasic.uid == AuthService.shared.currentUser!.uid {
                                    self!.coreData.addNewUser(core: uc)
                                    self!.currentUserCore = uc
                                }
                            }
                            promise(.success(uc))
                        }
                        .store(in: &self!.subs)
                }
            } else {
                promise(.failure(CRUDError.uidEmpty))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateUser(userCore: UserCore) -> void {
        if AuthService.shared.currentUser!.uid == userCore.userBasic.uid {
            currentUserCore = userCore
        }
        
        return Future<Void, Error> { [weak self] promise in
            self!.firebase.updateUser(userCore: userCore)
                .map{ _ in
                    self!.coreData.updateUser(userCore: userCore)
                }
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("UserCoreService: Failed to update UserCore w/ id -> \(userCore.userBasic.uid)")
                        print("UserCoreService-err: \(e)")
                        promise(.failure(e))
                    case .finished:
                        print("UserCoreService: Finished updating UserCore w/ id -> \(userCore.userBasic.uid)")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }.eraseToAnyPublisher()
    }
    
    func getUserCore_iOS15(uid: String) async -> UserCore? {
        let docRef = self.db.collection("UserCore").document(uid)

        do {
            let doc = try await docRef.getDocument()

            let date = doc.data()?["age"] as? String ?? ""
            let format = DateFormatter()
            format.dateFormat = "yyyy/MM/dd"

            let age = format.date(from: date)!

            let uid = doc.data()?["id"] as? String ?? ""
            let name = doc.data()?["name"] as? String ?? ""
            let ageFinal = age
            let gender = doc.data()?["gender"] as? String ?? ""
            let sexuality = doc.data()?["sexuality"] as? String ?? ""
            let ageMinPref = doc.data()?["ageMinPref"] as? Int ?? 18
            let ageMaxPref = doc.data()?["ageMaxPref"] as? Int ?? 99
            let willingToTravel = doc.data()?["willingToTravel"] as? Int ?? 25
            let longitude = doc.data()?["longitude"] as? Double ?? 0
            let latitude = doc.data()?["latitude"] as? Double ?? 0

            let userCore = UserCore(
                userBasic: UserBasic(
                    uid: uid,
                    name: name,
                    birthdate: ageFinal,
                    gender: gender,
                    sexuality: sexuality
                ),
                ageRangePreference: AgeRangePreference(minAge: ageMinPref, maxAge: ageMaxPref),
                searchRadiusComponents: SearchRadiusComponents(
                    coordinate: Coordinate(lat: latitude, lng: longitude),
                    willingToTravel: willingToTravel
                )
            )
            
            if uid == AuthService.shared.currentUser!.uid {
                self.currentUserCore = userCore
                print("UserCoreService: setting CurrentUserCore: \(String(describing: self.currentUserCore))")
            }

            return userCore
        } catch {
            print("UserCoreService: Failed to fetch UserCore w/ id: \(uid)")
            print("UserCoreService-err: \(error)")
            return nil
        }
    }
}

enum UserCoreError: Error {
    case emptyUID
    case missingFields
    case noDocumentFound
}
