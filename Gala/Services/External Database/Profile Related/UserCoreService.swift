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
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error>
    func getUserCore(uid: String?) -> AnyPublisher<UserCore?, Error>
    func updateUser(userCore: UserCore) -> AnyPublisher<Void, Error>
}

class UserCoreService: ObservableObject, UserCoreServiceProtocol {
    @Published var currentUserCore: UserCore?
    
    private let db = Firestore.firestore()
    private let currentUID = AuthService.shared.currentUser?.uid
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = UserCoreService()
    private init() {}
    
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error> {
        let lat: Double = LocationService.shared.coordinates.latitude
        let long: Double = LocationService.shared.coordinates.longitude
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let hash = GFUtils.geoHash(forLocation: location)
        
        if core.userBasic.uid == AuthService.shared.currentUser?.uid {
            print("UserCoreService-addNewUser: Setting currentUserCore")
            self.currentUserCore = core
            print("CurrentUserCore: \(String(describing: self.currentUserCore))")
        }
        
        return Future<Void, Error> { promise in
            self.db.collection("UserCore").document(core.userBasic.uid).setData([
                "name" : core.userBasic.name,
                "age" : core.userBasic.birthdate.formatDate(),
                "dateJoined" : Date().formatDate(),
                "geoHash" : hash,
                "latitude" : lat,
                "longitude" : long,
                "gender" : core.userBasic.gender,
                "sexuality" : core.userBasic.sexuality,
                "ageMinPref" : core.ageRangePreference.minAge,
                "ageMaxPref" : core.ageRangePreference.maxAge,
                "willingToTravel" : core.searchRadiusComponents.willingToTravel,
                "id" : core.userBasic.uid
            ]) { err in
                if let err = err {
                    print("UserCoreService: \(err)")
                    promise(.failure(err))
                } else {
                    print("UserCoreService: new user successfully written")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getUserCore(uid: String?) -> AnyPublisher<UserCore?, Error> {
        return Future<UserCore?, Error> { promise in
            if let uid = uid  {
                let docRef = self.db.collection("UserCore").document(uid)
                
                docRef.getDocument { [weak self] (document, error) in
                    
                    if let error = error { promise(.failure(error)) }
                    
                    if let doc = document {
                        
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
                        print("UserCoreService: setting CurrentUserCore: \(String(describing: userCore))")
                        print("UserCoreService: setting CurrentUserCore: \(String(describing: self?.currentUID))")
                        
                        if uid == AuthService.shared.currentUser?.uid{
                            self?.currentUserCore = userCore
                            print("UserCoreService: setting CurrentUserCore: \(String(describing: self?.currentUserCore))")
                        }
                        
                        promise(.success(userCore))
                        
                    } else {
                        promise(.failure(UserCoreError.noDocumentFound))
                    }
                }
            } else {
                promise(.failure(UserCoreError.emptyUID))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateUser(userCore: UserCore) -> AnyPublisher<Void, Error> {
        return addNewUser(core: userCore)
    }
    
    func getUserCore_iOS15(uid: String) async -> UserCore? {
        let docRef = self.db.collection("UserCore").document(uid)

        do {
            let doc = try await docRef.getDocument()
            
            let date = doc.data()?["age"] as? String ?? ""
            let format = DateFormatter()
            format.dateFormat = "yyyy/MM/dd"
            
            let age = format.date(from: date)!
            
            //                    print("UserCore birthday: \(age)")
            //                    print("UserCore age: \(age.ageString())")
            
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
            
            print("UserCoreService: setting CurrentUserCore: \(String(describing: userCore))")
            print("UserCoreService: setting CurrentUserCore: \(String(describing: self.currentUID))")
            if uid == self.currentUID{
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
