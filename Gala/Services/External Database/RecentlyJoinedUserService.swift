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
    private let currentUID = AuthService.shared.currentUser?.uid
    private let userCore = UserCoreService.shared.currentUserCore
        
    private var cancellables: [AnyCancellable] = []
    
    static let shared = RecentlyJoinedUserService()
    private init() {}
    
    func addNewUser(core: UserCore) -> AnyPublisher<Void, Error> { return addNewUser_(core) }
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
            self.db.collection("RecentlyJoined").document(self.currentUID!).setData([
                "name" : core.name,
                "age" : core.age.formatDate(),
                "dateJoined" : Date().formatDate(),
                "geoHash" : hash,
                "latitude" : lat,
                "longitude" : long,
                "gender" : core.gender,
                "sexuality" : core.sexuality,
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
}


//MARK: - getRecents()
extension RecentlyJoinedUserService {
    
    private enum CurrentUserSexualityAndGender {
        case straightMale
        case gayMale
        case biMale
        
        case straightFemale
        case gayFemale
        case biFemale
    }
    
    private func getCurrentUserSexualityAndGender() -> CurrentUserSexualityAndGender {
        //print("RecentlyJoinedUserService: \(String(describing: userCore))")
        if userCore?.gender == "male" {
            if userCore?.sexuality == "straight" {
                print("RecentlyJoinedUserService: Straight male")
                return .straightMale
            
            } else if userCore?.sexuality == "gay"{
                return .gayMale
                
            } else {
                return .biMale
            }
        } else {
            if userCore?.sexuality == "straight" {
                return .straightFemale
                
            } else if userCore?.sexuality == "gay"{
                return .gayFemale
                
            } else {
                return .biFemale
            }
        }
    }
    
    private func getRecents_() -> AnyPublisher<[UserCore]?, Error> {
        
        let sexaulityAndGender = getCurrentUserSexualityAndGender()
        
        return Future<[UserCore]?, Error> { promise in
            
            var userCore1: [UserCore]? = nil
            var error1: Error? = nil
            
            var userCore2: [UserCore]? = nil
            var error2: Error? = nil

            var userCore3: [UserCore]? = nil
            var error3: Error? = nil

            var userCore4: [UserCore]? = nil
            var error4: Error? = nil

            print("RecentlyJoinedUserService: Entered getRecents_()")
            
            switch sexaulityAndGender {

            case .straightMale:
                //Get straight and bi women
                self.getRecents(forRadiusKM: 50, forGender: "female", forSexuality: "straight", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                            error1 = error
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching straight females")
                        }
                    } receiveValue: { straightFemales in
                        if let straightFemales = straightFemales {
                            userCore1 = straightFemales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyStraightFemale
                            error1 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "female", forSexuality: "bisexual", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                            error2 = error
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching bisexual females")
                        }
                    } receiveValue: { biFemales in
                        if let biFemales = biFemales {
                            userCore2 = biFemales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyBiFemale
                            error2 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                while userCore1 == nil && error1 == nil {}
                while userCore2 == nil && error2 == nil {}
                
                if userCore1 != nil && userCore2 != nil {
                    let users: [UserCore] = userCore1! + userCore2!
                    promise(.success(users))
                } else if userCore1 != nil && userCore2 == nil {
                    promise(.success(userCore1))
                } else if userCore1 == nil && userCore2 != nil {
                    promise(.success(userCore2))
                } else {
                    let error: RecentlyJoinedError = .failedToLoadUsers_StraightMale
                    promise(.failure(error))
                }
                
            case .gayMale:
                //Get gay men and bi men
                self.getRecents(forRadiusKM: 50, forGender: "male", forSexuality: "gay", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                            error1 = error
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching gay males")
                        }
                    } receiveValue: { gayMales in
                        if let gayMales = gayMales {
                            userCore1 = gayMales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyGayMale
                            error1 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "male", forSexuality: "bisexual", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                            error2 = error
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching bisexual males")
                        }
                    } receiveValue: { biMales in
                        if let biMales = biMales {
                            userCore2 = biMales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyBiMale
                            error2 = error
                        }
                    }
                    .store(in: &self.cancellables)

                while userCore1 == nil && error1 == nil {}
                while userCore2 == nil && error2 == nil {}
                
                if userCore1 != nil && userCore2 != nil {
                    let users: [UserCore] = userCore1! + userCore2!
                    promise(.success(users))
                } else if userCore1 != nil && userCore2 == nil {
                    promise(.success(userCore1))
                } else if userCore1 == nil && userCore2 != nil {
                    promise(.success(userCore2))
                } else {
                    let error: RecentlyJoinedError = .failedToLoadUsers_GayMale
                    promise(.failure(error))
                }
                
            case .biMale:
                //Get straight women, bi women, gay men, bi men.
                self.getRecents(forRadiusKM: 50, forGender: "female", forSexuality: "straight", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                            error1 = error
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching straight females")
                        }
                    } receiveValue: { straightFemales in
                        if let straightFemales = straightFemales {
                            userCore1 = straightFemales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyStraightFemale
                            error1 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "female", forSexuality: "bisexual", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                            error2 = error
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching bisexual females")
                        }
                    } receiveValue: { biFemales in
                        if let biFemales = biFemales {
                            userCore2 = biFemales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyBiFemale
                            error2 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "male", forSexuality: "gay", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                            error3 = error
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching gay males")
                        }
                    } receiveValue: { gayMales in
                        if let gayMales = gayMales {
                            userCore3 = gayMales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyGayMale
                            error3 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "male", forSexuality: "bisexual", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                            error4 = error
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching bisexual males")
                        }
                    } receiveValue: { biMales in
                        if let biMales = biMales {
                            userCore4 = biMales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyBiMale
                            error4 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                while userCore1 == nil && error1 == nil {}
                while userCore2 == nil && error2 == nil {}
                while userCore3 == nil && error3 == nil {}
                while userCore4 == nil && error4 == nil {}
                
                var users: [UserCore] = []
                
                if userCore1 != nil {
                    users += userCore1!
                }
                
                if userCore2 != nil {
                    users += userCore2!
                }
                
                if userCore3 != nil {
                    users += userCore3!
                }
                
                if userCore4 != nil {
                    users += userCore4!
                }
                
                if users.count == 0 {
                    let error: RecentlyJoinedError = .failedToLoadUsers_BiMale
                    promise(.failure(error))
                } else {
                    promise(.success(users))
                }
                

            case .straightFemale:
                //Get straight and bi men
                self.getRecents(forRadiusKM: 50, forGender: "male", forSexuality: "straight", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching straight males")
                        }
                    } receiveValue: { straightMales in
                        if let straightMales = straightMales {
                            userCore1 = straightMales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyStraightMale
                            error1 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "male", forSexuality: "bisexual", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching bisexual males")
                        }
                    } receiveValue: { biMales in
                        if let biMales = biMales {
                            userCore2 = biMales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyBiMale
                            error2 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                while userCore1 == nil && error1 == nil {}
                while userCore2 == nil && error2 == nil {}
                
                if userCore1 != nil && userCore2 != nil {
                    let users: [UserCore] = userCore1! + userCore2!
                    promise(.success(users))
                } else if userCore1 != nil && userCore2 == nil {
                    promise(.success(userCore1))
                } else if userCore1 == nil && userCore2 != nil {
                    promise(.success(userCore2))
                } else {
                    let error: RecentlyJoinedError = .failedToLoadUsers_StraightFemale
                    promise(.failure(error))
                }

            case .gayFemale:
                //Get gay women and bi women
                self.getRecents(forRadiusKM: 50, forGender: "female", forSexuality: "gay", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching gay females")
                        }
                    } receiveValue: { gayFemales in
                        if let gayFemales = gayFemales{
                            userCore1 = gayFemales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyGayFemale
                            error1 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "female", forSexuality: "bisexual", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching bisexual females")
                        }
                    } receiveValue: { biFemales in
                        if let biFemales = biFemales {
                            userCore2 = biFemales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyBiFemale
                            error2 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                while userCore1 == nil && error1 == nil {}
                while userCore2 == nil && error2 == nil {}
                
                if userCore1 != nil && userCore2 != nil {
                    let users: [UserCore] = userCore1! + userCore2!
                    promise(.success(users))
                } else if userCore1 != nil && userCore2 == nil {
                    promise(.success(userCore1))
                } else if userCore1 == nil && userCore2 != nil {
                    promise(.success(userCore2))
                } else {
                    let error: RecentlyJoinedError = .failedToLoadUsers_GayFemale
                    promise(.failure(error))
                }

            case .biFemale:
                //Get straight men, bi men, gay women, bi women
                self.getRecents(forRadiusKM: 50, forGender: "male", forSexuality: "straight", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching straight males")
                        }
                    } receiveValue: { straightMales in
                        if let straightMales = straightMales {
                            userCore1 = straightMales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyStraightMale
                            error1 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "male", forSexuality: "bisexual", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching bisexual males")
                        }
                    } receiveValue: { biMales in
                        if let biMales = biMales {
                            userCore2 = biMales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyBiMale
                            error2 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "female", forSexuality: "gay", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching gay females")
                        }
                    } receiveValue: { gayFemales in
                        if let gayFemales = gayFemales {
                            userCore3 = gayFemales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyGayFemale
                            error3 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                self.getRecents(forRadiusKM: 50, forGender: "female", forSexuality: "bisexual", ageMin: 18, ageMax: 24)
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("RecentlyJoinedService: \(error)")
                        case .finished:
                            print("RecentlyJoinedService: Finished fetching bisexual females")
                        }
                    } receiveValue: { biFemales in
                        if let biFemales = biFemales {
                            userCore4 = biFemales
                        } else {
                            let error: RecentlyJoinedError = .returnedEmptyBiFemale
                            error4 = error
                        }
                    }
                    .store(in: &self.cancellables)
                
                while userCore1 == nil && error1 == nil {}
                while userCore2 == nil && error2 == nil {}
                while userCore3 == nil && error3 == nil {}
                while userCore4 == nil && error4 == nil {}
                
                var users: [UserCore] = []
                
                if userCore1 != nil {
                    users += userCore1!
                }
                
                if userCore2 != nil {
                    users += userCore2!
                }
                
                if userCore3 != nil {
                    users += userCore3!
                }
                
                if userCore4 != nil {
                    users += userCore4!
                }
                
                if users.count == 0 {
                    let error: RecentlyJoinedError = .failedToLoadUsers_BiFemale
                    promise(.failure(error))
                } else {
                    promise(.success(users))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func getRecents(forRadiusKM: Double, forGender: String, forSexuality: String, ageMin: Int, ageMax: Int) -> AnyPublisher<[UserCore]?, Error> {
        
        return Future<[UserCore]?, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
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
            
            print("UserCoreService: \(queries.count)")
            
            var results: [UserCore] = []
            for i in 0..<queries.count {
                queries[i].getDocuments { snap, error in
                    if let documents = snap?.documents {
                        for j in 0..<documents.count {
                            
                            let date = documents[j].data()["age"] as? String ?? ""
                            let format = DateFormatter()
                            format.dateFormat = "yyyy/MM/dd"
                            let age = format.date(from: date)!

                            if date <= ageMinString && date >= ageMaxString {
                                let gender = documents[j].data()["gender"] as? String ?? ""
                                let id = documents[j].data()["id"] as? String ?? ""
                                let lat = documents[j].data()["latitude"] as? Double ?? 0
                                let lng = documents[j].data()["longitude"] as? Double ?? 0
                                let name = documents[j].data()["name"] as? String ?? ""
                                let sexuality = documents[j].data()["sexuality"] as? String ?? ""

                                let uSimp = UserCore(uid: id, name: name, age: age, gender: gender, sexuality: sexuality, longitude: lng, latitude: lat)
                                
                                results.append(uSimp)
                            }
                            
                            if j == (documents.count - 1) {
                                promise(.success(results))
                            }
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
    }
}
