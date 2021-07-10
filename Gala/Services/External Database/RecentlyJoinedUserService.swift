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

protocol RecentlyJoinedUserServiceProtocol {
    func addNewUser(userSimple: UserSimpleModel) -> AnyPublisher<Void, Error>
    func getAllRecents() -> AnyPublisher<UserSimpleModel, Error>
}

class RecentlyJoinedUserService: ObservableObject, RecentlyJoinedUserServiceProtocol {
    
    private let db = Firestore.firestore()
    private let currentUID = UserService.shared.currentUser?.uid
    
    static let shared = RecentlyJoinedUserService()
    private init() {}
    
    func addNewUser(userSimple: UserSimpleModel) -> AnyPublisher<Void, Error> {
//        let lat: Double = (round(LocationService.shared.coordinates.latitude * 10000) / 10000)
//        let long: Double = (round(LocationService.shared.coordinates.longitude * 10000) / 10000)
        let lat: Double = LocationService.shared.coordinates.latitude
        let long: Double = LocationService.shared.coordinates.longitude
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let hash = GFUtils.geoHash(forLocation: location)
        
        return Future<Void, Error> { promise in
            self.db.collection("RecentlyJoined").document(self.currentUID!).setData([
                "name" : userSimple.name,
                "age" : Timestamp(date: userSimple.age),
                "dateJoined" : Date(),
                "geoHash" : hash,
                "latitude" : lat,
                "longitude" : long,
                "gender" : userSimple.gender,
                "sexuality" : userSimple.sexuality,
                "id" : userSimple.uid
            ]) { err in
                if let err = err {
                    print("RecentlyJoinedUserService: \(err)")
                    promise(.failure(err))
                } else {
                    print("RecentlyJoinedUser successfully written: RecentlyJoinedUserService")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getAllRecents() -> AnyPublisher<UserSimpleModel, Error> {
        return Future<UserSimpleModel, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
