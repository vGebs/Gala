//
//  RecentlyJoinedUserService.swift
//  Gala
//
//  Created by Vaughn on 2021-07-08.
//

import Combine
import CoreLocation
import GeoFire
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol UserCoreServiceProtocol {
    var currentUserCore: UserCore? { get set }
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error>
    func getUserCore(uid: String) -> AnyPublisher<UserCore?, Error>
}

class UserCoreService: ObservableObject, UserCoreServiceProtocol {
    var currentUserCore: UserCore?
    
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
        
        if core.uid == currentUID {
            print("UserCoreService-addNewUser: Setting currentUserCore")
            self.currentUserCore = core
            print("CurrentUserCore: \(String(describing: self.currentUserCore))")
        }
        
        return Future<Void, Error> { promise in
            self.db.collection("UserCore").document(self.currentUID!).setData([
                "name" : core.name,
                "age" : core.age.formatDate(),
                "dateJoined" : Date().formatDate(),
                "geoHash" : hash,
                "latitude" : lat,
                "longitude" : long,
                "gender" : core.gender,
                "sexuality" : core.sexuality,
                "ageMinPref" : core.ageMinPref,
                "ageMaxPref" : core.ageMaxPref,
                "id" : core.uid
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
    
    func getUserCore(uid: String) -> AnyPublisher<UserCore?, Error> {
        return Future<UserCore?, Error> { promise in
            let docRef = self.db.collection("UserCore").document(uid)
            
            docRef.getDocument { (document, error) in
                
                if let error = error { promise(.failure(error)) }
                
                if let doc = document {
                    
                    let date = doc.data()?["age"] as? String ?? ""
                    let format = DateFormatter()
                    format.dateFormat = "yyyy/MM/dd"
                    
                    let age = format.date(from: date)!
                    
//                    print("UserCore birthday: \(age)")
//                    print("UserCore age: \(age.ageString())")
                    
                    let userCore = UserCore(
                        uid: doc.data()?["id"] as? String ?? "",
                        name: doc.data()?["name"] as? String ?? "",
                        age: age,
                        gender: doc.data()?["gender"] as? String ?? "",
                        sexuality: doc.data()?["sexuality"] as? String ?? "",
                        ageMinPref: doc.data()?["ageMinPref"] as? Int ?? 18,
                        ageMaxPref: doc.data()?["ageMaxPref"] as? Int ?? 99,
                        longitude: doc.data()?["longitude"] as? Double ?? 0,
                        latitude: doc.data()?["latitude"] as? Double ?? 0
                    )
                    print("UserCoreService: setting CurrentUserCore: \(String(describing: userCore))")
                    print("UserCoreService: setting CurrentUserCore: \(String(describing: self.currentUID))")
                    if uid == self.currentUID{
                        self.currentUserCore = userCore
                        print("UserCoreService: setting CurrentUserCore: \(String(describing: self.currentUserCore))")
                    }
                    
                    promise(.success(userCore))
                    
                }
                promise(.success(nil))
            }
        }.eraseToAnyPublisher()
    }
}
