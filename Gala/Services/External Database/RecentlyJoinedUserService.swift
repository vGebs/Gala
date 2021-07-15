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
    func getAllRecents(radiusKM: Double) -> AnyPublisher<[UserSimpleModel], Error>
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
    
    func getAllRecents(radiusKM: Double) -> AnyPublisher<[UserSimpleModel], Error> {
        return Future<[UserSimpleModel], Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let radiusInM: Double = radiusKM * 1000

            let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radiusInM)
            
            let queries = queryBounds.map { bound -> Query in
                return self.db.collection("RecentlyJoined")
                    .order(by: "geoHash")
                    .start(at: [bound.startValue])
                    .end(at: [bound.endValue])
            }
            
            print("RecentlyJoinedUserService: \(queries.count)")
            
            var results: [UserSimpleModel] = []
            
            for i in 0..<queries.count {
                queries[i].getDocuments { snap, error in
                    if let documents = snap?.documents {
                        for j in 0..<documents.count {
                            var age = Date()
                            
                            if let date = documents[j].data()["age"] as? Timestamp {
                                age = date.dateValue()
                            }
                            
                            let gender = documents[j].data()["gender"] as? String ?? ""
                            let id = documents[j].data()["id"] as? String ?? ""
                            let lat = documents[j].data()["latitude"] as? Double ?? 0
                            let lng = documents[j].data()["longitude"] as? Double ?? 0
                            let name = documents[j].data()["name"] as? String ?? ""
                            let sexuality = documents[j].data()["sexuality"] as? String ?? ""
                            
                            let uSimp = UserSimpleModel(uid: id, name: name, age: age, gender: gender, sexuality: sexuality, longitude: lng, latitude: lat)
                            
                            print("RecentlyJoinedUserService UserSimple: \(uSimp)")

                            results.append(uSimp)
                            
                            if j == (documents.count - 1) {
                                promise(.success(results))
                            }
                            
                            //                    let coordinates = CLLocation(latitude: lat, longitude: lng)
                            //                    let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
                            //
                            //                    // We have to filter out a few false positives due to GeoHash accuracy, but
                            //                    // most will match
                            //                    let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                            //                    if distance <= radiusInM {
                            //                        matchingDocs.append(document)
                            //                    }
                        }
                    } else {
                        print("Unable to fetch snapshot data. \(String(describing: error))")
                        promise(.failure(error!))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
