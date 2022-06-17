//
//  UserCoreFirebase.swift
//  Gala
//
//  Created by Vaughn on 2022-04-13.
//

import Combine
import CoreLocation
import GeoFire
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserCoreService_Firebase: UserCoreServiceProtocol {
    private let db = Firestore.firestore()
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = UserCoreService_Firebase()
    private init() {}
    
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error> {
        let lat: Double = LocationService.shared.coordinates.latitude
        let long: Double = LocationService.shared.coordinates.longitude
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let hash = GFUtils.geoHash(forLocation: location)
        
        return Future<Void, Error> { promise in
            self.db.collection("UserCore").document(core.userBasic.uid).setData([
                "name" : core.userBasic.name,
                "age" : core.userBasic.birthdate.formatDate(),
                "dateJoined" : Date(),
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
                
                docRef.getDocument { (document, error) in
                    
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
                        
                        if uid == AuthService.shared.currentUser!.uid {
                            let dateJoinedTimestamp = doc.data()?["dateJoined"] as? Timestamp
                            let dateJoined = dateJoinedTimestamp?.dateValue()
                            
                            if let joined = dateJoined {
                                let userCore = UserCore(
                                    userBasic: UserBasic(
                                        uid: uid,
                                        name: name,
                                        birthdate: ageFinal,
                                        gender: gender,
                                        sexuality: sexuality,
                                        dateJoined: joined
                                    ),
                                    ageRangePreference: AgeRangePreference(minAge: ageMinPref, maxAge: ageMaxPref),
                                    searchRadiusComponents: SearchRadiusComponents(
                                        coordinate: Coordinate(lat: latitude, lng: longitude),
                                        willingToTravel: willingToTravel
                                    )
                                )
                                promise(.success(userCore))
                            }
                        } else {
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
                            promise(.success(userCore))
                        }
                        
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
        //when we update userCore we also need to check if the current user isnt recently joined
        //  if they are recently joined we need to updat the recentlyJoinedProfile
        checkDateJoined(userCore)
        
        //we also need to check if they have any stories
        //  if they do, we update that document as well
        checkStories(userCore)
        
        let lat: Double = LocationService.shared.coordinates.latitude
        let long: Double = LocationService.shared.coordinates.longitude
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let hash = GFUtils.geoHash(forLocation: location)
        
        return Future<Void, Error> { [weak self] promise in
            self?.db.collection("UserCore").document(userCore.userBasic.uid).updateData([
                "ageMaxPref" : userCore.ageRangePreference.maxAge,
                "ageMinPref" : userCore.ageRangePreference.minAge,
                "gender" : userCore.userBasic.gender,
                "sexuality" : userCore.userBasic.sexuality,
                "geoHash" : hash,
                "latitude" : lat,
                "longitude" : long,
                "willingToTravel" : userCore.searchRadiusComponents.willingToTravel
            ]) { err in
                if let e = err {
                    print("UserCoreService_Firebase: Failed to update userCore")
                    promise(.failure(e))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func observeUserCore(with uid: String, completion: @escaping (UserCore?) -> Void) {
        db.collection("UserCore").document(uid)
            .addSnapshotListener { snapShot, error in
                guard let data = snapShot?.data() else {
                    completion(nil)
                    return
                }
                
                let date = data["age"] as? String ?? ""
                let format = DateFormatter()
                format.dateFormat = "yyyy/MM/dd"
                
                let age = format.date(from: date)!
                
                let uid = data["id"] as? String ?? ""
                let name = data["name"] as? String ?? ""
                let ageFinal = age
                let gender = data["gender"] as? String ?? ""
                let sexuality = data["sexuality"] as? String ?? ""
                let ageMinPref = data["ageMinPref"] as? Int ?? 18
                let ageMaxPref = data["ageMaxPref"] as? Int ?? 99
                let willingToTravel = data["willingToTravel"] as? Int ?? 25
                let longitude = data["longitude"] as? Double ?? 0
                let latitude = data["latitude"] as? Double ?? 0
                
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
                
                completion(userCore)
            }
    }
}

extension UserCoreService_Firebase {
    private func checkDateJoined(_ userCore: UserCore) {
        if let currentUserCore = UserCoreService.shared.currentUserCore {
            if let dateJoined = currentUserCore.userBasic.dateJoined {
                if let diff = Calendar.current.dateComponents([.hour], from: dateJoined, to: Date()).hour, diff < 168 {
                    //updateRecentlyJoined
                    print("we're in mother fucker")
                    RecentlyJoinedUserService.shared.updateUser(core: userCore)
                        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .failure(let e):
                                print("UserCoreService_Firebase: Failed to update recentlyJoined profile")
                                print("UserCoreService_Firebase-err: \(e)")
                            case .finished:
                                print("UserCoreService_Firebase: Finished updating recentlyJoined profile")
                            }
                        } receiveValue: { _ in }
                        .store(in: &cancellables)
                }
            }
        }
    }
    
    private func checkStories(_ userCore: UserCore) {
        if DataStore.shared.stories.myStories.count > 0 {
            //update story document
            StoryMetaService.shared.updateStory(userCore: userCore)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("UserCoreService_Firebase: Failed to update story document")
                        print("UserCoreService_Firebase-err: \(e)")
                    case .finished:
                        print("UserCoreService_Firebase: Finished updating story document")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
    }
}
