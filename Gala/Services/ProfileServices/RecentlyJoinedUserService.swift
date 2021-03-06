//
//  RecentlyJoinedUserService.swift
//  Gala
//
//  Created by Vaughn on 2021-07-25.
//

import Combine
import SwiftUI
import CoreLocation
import GeoFire
import FirebaseFirestore

protocol RecentlyJoinedUserServiceProtocol {
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error>
    func getRecents() -> AnyPublisher<[UserCore]?, Error>
}

class RecentlyJoinedUserService: RecentlyJoinedUserServiceProtocol {
    
    private let db = Firestore.firestore()
    private let userCore = UserCoreService.shared.currentUserCore
        
    private var cancellables: [AnyCancellable] = []
    
    static let shared = RecentlyJoinedUserService()
    private init() { }
    
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error> { return addNewUser_(core) }
    
    func updateUser(core: UserCore) -> AnyPublisher<Void, Error> { return updateUser_(core) }
    
    func getRecents() -> AnyPublisher<[UserCore]?, Error> { return getRecents_() }
}

//MARK: - addNewUser()
extension RecentlyJoinedUserService {
    
    private func addNewUser_(_ core: UserCore) -> AnyPublisher<Void, Error> {
        let lat: Double = LocationService.shared.coordinates.latitude
        let long: Double = LocationService.shared.coordinates.longitude
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let hash = GFUtils.geoHash(forLocation: location)
        
        return Future<Void, Error> { promise in
            self.db.collection("RecentlyJoined").document(AuthService.shared.currentUser!.uid).setData([
                "name" : core.userBasic.name,
                "age" : core.userBasic.birthdate.formatDate(),
                "dateJoined" : core.userBasic.dateJoined ?? Date(),
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
    
    private func updateUser_(_ core: UserCore) -> AnyPublisher<Void, Error> {
        let lat: Double = LocationService.shared.coordinates.latitude
        let long: Double = LocationService.shared.coordinates.longitude
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let hash = GFUtils.geoHash(forLocation: location)
        
        return Future<Void, Error> { [weak self] promise in
            self?.db.collection("RecentlyJoined").document(core.userBasic.uid).updateData([
                "ageMaxPref" : core.ageRangePreference.maxAge,
                "ageMinPref" : core.ageRangePreference.minAge,
                "gender" : core.userBasic.gender,
                "sexuality" : core.userBasic.sexuality,
                "geoHash" : hash,
                "latitude" : lat,
                "longitude" : long,
                "willingToTravel" : core.searchRadiusComponents.willingToTravel
            ]) { err in
                if let e = err {
                    print("RecentlyJoinedService: Failed to update userCore")
                    promise(.failure(e))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}


//MARK: - getRecents()
extension RecentlyJoinedUserService {
        
    private func getRecents_() -> AnyPublisher<[UserCore]?, Error> {
        
        let sexaulityAndGender = getCurrentUserSexualityAndGender()
        let ageMinPref = UserCoreService.shared.currentUserCore?.ageRangePreference.minAge
        let ageMaxPref = UserCoreService.shared.currentUserCore?.ageRangePreference.maxAge
        let travelDistance = UserCoreService.shared.currentUserCore?.searchRadiusComponents.willingToTravel

        return Future<[UserCore]?, Error> { promise in
            
            switch sexaulityAndGender {

            case .straightMale:
                //Get straight and bi women
                Publishers.Zip(
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "straight", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("RecentlyJoinedUserService-getRecents_(): Failed to load users for straight male: \(error.localizedDescription)")
                    case .finished:
                        print("RecentlyJoinedUserService-getRecents_(): Finished fetching users for straight males")
                    }
                } receiveValue: { straightFemales, biFemales in
                    var final: [UserCore] = []
                    if let sF = straightFemales {
                        final += sF
                    }
                    if let bF = biFemales {
                        final += bF
                    }
                    promise(.success(final))
                }
                .store(in: &self.cancellables)
                
            case .gayMale:
                //Get gay men and bi men
                Publishers.Zip(
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "gay", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("RecentlyJoinedUserService-getRecents_(): Failed to load users for gay male: \(error.localizedDescription)")
                    case .finished:
                        print("RecentlyJoinedUserService-getRecents_(): Finished fetching users for gay males")
                    }
                } receiveValue: { gayMales, biMales in
                    var final: [UserCore] = []
                    if let gM = gayMales {
                        final += gM
                    }
                    if let bM = biMales {
                        final += bM
                    }
                    promise(.success(final))
                }
                .store(in: &self.cancellables)
                
            case .biMale:
                //Get straight women, bi women, gay men, bi men.
                Publishers.Zip4(
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "straight", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "gay", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("RecentlyJoinedUserService-getRecents_(): Failed to load users for bi male: \(error.localizedDescription)")
                    case .finished:
                        print("RecentlyJoinedUserService-getRecents_(): Finished fetching users for bi males")
                    }
                } receiveValue: { sF, bF, gM, bM in
                    var final: [UserCore] = []
                    if let sF = sF {
                        final += sF
                    }
                    if let bF = bF {
                        final += bF
                    }
                    if let gM = gM {
                        final += gM
                    }
                    if let bM = bM {
                        final += bM
                    }
                    promise(.success(final))
                }
                .store(in: &self.cancellables)
               
            case .straightFemale:
                //Get straight and bi men
                Publishers.Zip(
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "straight", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("RecentlyJoinedUserService-getRecents_(): Failed to load users for straight female: \(error.localizedDescription)")
                    case .finished:
                        print("RecentlyJoinedUserService-getRecents_(): Finished fetching users for straight female")
                    }
                } receiveValue: { sM, bM in
                    var final: [UserCore] = []
                    if let sM = sM {
                        final += sM
                    }
                    if let bM = bM {
                        final += bM
                    }
                    promise(.success(final))
                }
                .store(in: &self.cancellables)
                
            case .gayFemale:
                //Get gay women and bi women
                Publishers.Zip(
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "gay", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("RecentlyJoinedUserService-getRecents_(): Failed to load users for gay female: \(error.localizedDescription)")
                    case .finished:
                        print("RecentlyJoinedUserService-getRecents_(): Finished fetching users for gay female")
                    }
                } receiveValue: { gF, bF in
                    var final: [UserCore] = []
                    if let gF = gF {
                        final += gF
                    }
                    if let bF = bF {
                        final += bF
                    }
                    promise(.success(final))
                }
                .store(in: &self.cancellables)

            case .biFemale:
                //Get straight men, bi men, gay women, bi women
                Publishers.Zip4(
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "straight", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "gay", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getRecents(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("RecentlyJoinedUserService-getRecents_(): Failed to load users for bi female: \(error.localizedDescription)")
                    case .finished:
                        print("RecentlyJoinedUserService-getRecents_(): Finished fetching users for bi female")
                    }
                } receiveValue: { sM, bM, gF, bF in
                    var final: [UserCore] = []
                    if let sM = sM {
                        final += sM
                    }
                    if let bM = bM {
                        final += bM
                    }
                    if let gF = gF {
                        final += gF
                    }
                    if let bF = bF {
                        final += bF
                    }
                    promise(.success(final))
                }
                .store(in: &self.cancellables)

            }
        }.eraseToAnyPublisher()
    }
    
    private func getRecents(forRadiusKM: Double, forGender: String, forSexuality: String, ageMin: Int, ageMax: Int) -> AnyPublisher<[UserCore]?, Error> {
        
        return Future<[UserCore]?, Error> { promise in
            let lat: Double = UserCoreService.shared.currentUserCore!.searchRadiusComponents.coordinate.lat //LocationService.shared.coordinates.latitude
            let long: Double = UserCoreService.shared.currentUserCore!.searchRadiusComponents.coordinate.lng //LocationService.shared.coordinates.longitude
            
            
            
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let radiusInM: Double = forRadiusKM * 1000
            
            let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radiusInM)
            
            let ageMinString = ageMin.getDateForAge()
            let ageMaxString = ageMax.getDateForAge()

            // *TODO* Add a cloud function that checks for outdated users. *TODO*
            // *TODO* Add a cloud function that checks for changes in UserCore
            //              and update RecentlyJoined accordingly
            let queries = queryBounds.map { bound -> Query in
                return self.db.collection("RecentlyJoined")
                    .order(by: "geoHash")
                    .start(at: [bound.startValue])
                    .end(at: [bound.endValue])
                    .whereField("gender", isEqualTo: forGender)
                    .whereField("sexuality", isEqualTo: forSexuality)
                    .limit(to: 40)
            }
            
            var results: [UserCore] = []
            var finished = 0
            for i in 0..<queries.count {
                self.getDocs(query: queries[i], ageMinString: ageMinString, ageMaxString: ageMaxString)
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RJUS: \(error.localizedDescription)")
                        case .finished:
                            finished += 1
                        }
                    } receiveValue: { users in
                        if let users = users {
                            results += users
                        }
                        
                        if finished == queries.count - 1 {
                            promise(.success(results))
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    private func getDocs(query: Query, ageMinString: String, ageMaxString: String) -> AnyPublisher<[UserCore]?, Error> {
        return Future<[UserCore]?, Error> { promise in
            var results: [UserCore] = []
            query.getDocuments { snap, error in
                if let documents = snap?.documents {
                    if documents.count == 0 {
                        promise(.success(nil))
                    }
                    
                    for j in 0..<documents.count {
                        
                        let date = documents[j].data()["age"] as? String ?? ""
                        let format = DateFormatter()
                        format.dateFormat = "yyyy/MM/dd"
                        let age = format.date(from: date)!
                        
                        let ageMinPref = documents[j].data()["ageMinPref"] as? Int ?? 18
                        let ageMaxPref = documents[j].data()["ageMaxPref"] as? Int ?? 99
                        let myAge = Int((UserCoreService.shared.currentUserCore?.userBasic.birthdate.ageString())!)
                        
                        let willingToTravel = documents[j].data()["willingToTravel"] as? Int ?? 25
                        let lat = documents[j].data()["latitude"] as? Double ?? 0
                        let lng = documents[j].data()["longitude"] as? Double ?? 0
                        
                        if date <= ageMinString &&
                            date >= ageMaxString &&
                            (((ageMinPref - 1) <= myAge! &&
                            (ageMaxPref + 1) >= myAge!) ||
                                ageMaxPref == myAge! ||
                                ageMaxPref == myAge!) // Willing = 7, distance = 4
                            && willingToTravel >= LocationService.shared.getTravelDistance(to: CLLocation(latitude: lat, longitude: lng))
                        {
                            let gender = documents[j].data()["gender"] as? String ?? ""
                            let id = documents[j].data()["id"] as? String ?? ""
                            let name = documents[j].data()["name"] as? String ?? ""
                            let sexuality = documents[j].data()["sexuality"] as? String ?? ""
                            
                            let uc = UserCore(
                                userBasic: UserBasic(
                                    uid: id,
                                    name: name,
                                    birthdate: age,
                                    gender: gender,
                                    sexuality: sexuality
                                ),
                                ageRangePreference: AgeRangePreference(
                                    minAge: ageMinPref, maxAge: ageMaxPref
                                ),
                                searchRadiusComponents: SearchRadiusComponents(
                                    coordinate: Coordinate(lat: lat, lng: lng),
                                    willingToTravel: willingToTravel
                                )
                            )
                            
                            if id != AuthService.shared.currentUser!.uid {
                                results.append(uc)
                            }
                            
                            if j == (documents.count - 1){
                                promise(.success(results))
                            }
                        }
                    }
                } else {
                    print("Unable to fetch snapshot data. \(String(describing: error))")
                    promise(.failure(error!))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension RecentlyJoinedUserService {
    private enum RecentlyJoinedError: Error {
        case failedToLoadUsers_StraightMale
        case failedToLoadUsers_GayMale
        case failedToLoadUsers_BiMale
        
        case failedToLoadUsers_StraightFemale
        case failedToLoadUsers_GayFemale
        case failedToLoadUsers_BiFemale
        
        case returnedEmptyStraightMale
        case returnedEmptyGayMale
        case returnedEmptyBiMale
        
        case returnedEmptyStraightFemale
        case returnedEmptyGayFemale
        case returnedEmptyBiFemale
        
        case CurrentUserCoreEmpty
    }
}

// Option 1:
// UserCore (in root)
//
//The user creates an account                               *1 write*
//When the user needs to pull recently joined users         *1 read*
//  they need to query all users in the area and then
//  check for the dateJoined
//                          log(1,000,000)
//Because we cannot query for date directly with the
//  current setup, this is extremely inefficient
//  because we are getting a lot of other data we dont need

// Option 2:
// RecentlyJoined (in root)
//
//The user creates an account; pushes to UserCore &         *2 writes*
//  RecentlyJoined
//Add a listener that checks every minute to see if         *1 read/ min*
//  any new users are expired (1 week)
//
//This setup will be more efficient at pulling users
//  but will be more expensive $$$.
//
// Option 2 is the winner.
