//
//  StoryTextService.swift
//  Gala
//
//  Created by Vaughn on 2021-09-07.
//

import Combine
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import GeoFire

class StoryMetaService: ObservableObject {
    
    private let db = Firestore.firestore()
    
    private var currentUserCore = UserCoreService.shared.currentUserCore!
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = StoryMetaService()
    private init() {}
    
    func postStory(postID_date: Date, vibe: String) -> AnyPublisher<Void, Error> {
        //Fetch stories from db, check how many there are
        // If there isnt any, make a new post
        // If there is some, update the doc
        
        //If stories.count == 0 -> pushFirstStory
        // else -> pushAnotherStory
        self.getMyStories()
            .flatMap { stories in
                self.pushStory(postID_date, stories, vibe)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteStory(storyID: Date, vibe: String) -> AnyPublisher<Void, Error> {
        //If count == 1 -> deleteLastStory
        // otherwise -> deleteOneOfManyStories
        self.getMyStories()
            .flatMap { stories in
                self.deleteStory(storyID, stories, vibe)
            }
            .eraseToAnyPublisher()
    }
    
    func getMyStories() -> AnyPublisher<[StoryWithVibe], Error> {
        let currrentUser = UserCoreService.shared.currentUserCore!
        return Future<[StoryWithVibe], Error>{ promise in
            self.db.collection("Stories").document(currrentUser.uid)
                .getDocument { snap, err in
                    if let err = err {
                        print("StoryMetaService: Failed to fetch stories")
                        promise(.failure(err))
                    } else if let snap = snap {
                        var final: [StoryWithVibe] = []
                        if let posts = snap.data()?["posts"] as? [[String: Any]] {
                            for i in 0..<posts.count {
                                
                                let id = posts[i]["id"] as? Timestamp
                                let idFinal = id?.dateValue()
                                
                                let title = posts[i]["title"] as? String
                                
                                if let idd = idFinal, let title = title {
                                    let storyWithVibe = StoryWithVibe(pid: idd, title: title)
                                    //print(storyWithVibe)
                                    final.append(storyWithVibe)
                                }
                            }
                        }
                        promise(.success(final))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func getStories() -> AnyPublisher<[StoryMeta], Error> { self.getStories_() }
}

extension StoryMetaService {
    
    private func pushStory(_ postID: Date, _ stories: [StoryWithVibe], _ vibe: String) ->AnyPublisher<Void, Error> {
        if stories.count == 0 {
            return self.pushFirstStory(postID, vibe)
        } else {
            return self.pushAnotherStory(postID, vibe)
        }
    }
    
    private func pushFirstStory(_ postID_date: Date, _ vibe: String) -> AnyPublisher<Void, Error> {
        let currentUserCore = UserCoreService.shared.currentUserCore!
        return Future<Void, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hash = GFUtils.geoHash(forLocation: location)
            
            //Because we need to query these posts, we need to also add the current UserCore
            self.db.collection("Stories").document(currentUserCore.uid).setData([
                "userCore" : [
                    "uid" : currentUserCore.uid,
                    "name" : currentUserCore.name,
                    "birthday" : currentUserCore.age.formatDate(),
                    "gender" : currentUserCore.gender,
                    "sexuality" : currentUserCore.sexuality,
                    "agePref" : [
                        "min" : currentUserCore.ageMinPref,
                        "max" : currentUserCore.ageMaxPref,
                    ],
                    "willingToTravel" : currentUserCore.willingToTravel,
                    "location" : [
                        "geoHash" : hash,
                        "longitude" : currentUserCore.longitude,
                        "latitude" : currentUserCore.latitude,
                    ]
                ],
                "posts" : [
                    [
                        "id": postID_date,
                        "title": vibe
                    ]
                ]
            ]) { err in
                if let err = err {
                    print("StoryMetaService: Failed to post story meta")
                    promise(.failure(err))
                } else {
                    print("StoryMetaService: Successfully posted story meta")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func pushAnotherStory(_ postID_date: Date, _ vibe: String) -> AnyPublisher<Void, Error> {
        let currentUserCore = UserCoreService.shared.currentUserCore!
        return Future<Void, Error> { promise in
            let lat: Double = LocationService.shared.coordinates.latitude
            let long: Double = LocationService.shared.coordinates.longitude
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let hash = GFUtils.geoHash(forLocation: location)
            
            self.db.collection("Stories").document(currentUserCore.uid)
                .updateData([
                    "posts" : FieldValue.arrayUnion(
                        [
                            [
                                "id": postID_date,
                                "title": vibe
                            ]
                        ]
                    ),
                    "userCore.location.geoHash" : hash,
                    "userCore.location.latitude" : lat,
                    "userCore.location.longitude" : long
                ]) { err in
                    if let err = err {
                        print("StoryMetaService: Failed to push another story w/ id: \(postID_date)")
                        promise(.failure(err))
                    } else {
                        print("StoryMetaService: Successfully pushed another story w/ id: \(postID_date)")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
}

extension StoryMetaService {
    
    private func deleteStory(_ postID: Date, _ stories: [StoryWithVibe], _ vibe: String) -> AnyPublisher<Void, Error> {
        if stories.count == 1 {
            return self.deleteLastStory()
        } else {
            return self.deleteOneOfManyStories(storyID: postID, vibe: vibe)
        }
    }
    
    private func deleteLastStory() -> AnyPublisher<Void, Error> {
        let currentUser = UserCoreService.shared.currentUserCore!
        
        return Future<Void, Error>{ promise in
            self.db.collection("Stories").document(currentUser.uid)
                .delete() { err in
                    if let err = err {
                        print("StoryMetaService: Failed to delete last post")
                        promise(.failure(err))
                    } else {
                        print("StoryMetaService: Successfully deleted last story")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    private func deleteOneOfManyStories(storyID: Date, vibe: String) -> AnyPublisher<Void, Error> {
        let currentUser = UserCoreService.shared.currentUserCore!

        return Future<Void, Error> { promise in
            self.db.collection("Stories").document(currentUser.uid)
                .updateData([
                    "posts" : FieldValue.arrayRemove(
                        [
                            [
                                "id": storyID,
                                "title" : vibe
                            ]
                        ]
                    )
                ]) { err in
                    if let err = err {
                        print("StoryMetaService: Failed to delete Story")
                        promise(.failure(err))
                    } else {
                        print("StoryMetaService: Successfully deleted story")
                        promise(.success(()))
                    }
                }
        }.eraseToAnyPublisher()
    }
}

extension StoryMetaService {
    private func getStories_() -> AnyPublisher<[StoryMeta], Error> {
        
        let sexaulityAndGender = getCurrentUserSexualityAndGender()
        let ageMinPref = UserCoreService.shared.currentUserCore?.ageMinPref
        let ageMaxPref = UserCoreService.shared.currentUserCore?.ageMaxPref
        let travelDistance = UserCoreService.shared.currentUserCore?.willingToTravel
        
        return Future<[StoryMeta], Error> { promise in

            //print("RecentlyJoinedUserService: Entered getRecents_()")
            
            switch sexaulityAndGender {

            case .straightMale:
                //Get straight and bi women
                Publishers.Zip(
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "straight", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("StoryMetaService-getStories_(): Failed to load users for straight male: \(error.localizedDescription)")
                    case .finished:
                        print("StoryMetaService-getStories_(): Finished fetching users for straight males")
                    }
                } receiveValue: { straightFemales, biFemales in
                    var final: [StoryMeta] = []
                    
                    final += straightFemales
                    final += biFemales
                    
                    promise(.success(final))
                }
                .store(in: &self.cancellables)
                
            case .gayMale:
                //Get gay men and bi men
                Publishers.Zip(
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "gay", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("StoryMetaService-getStories_(): Failed to load users for gay male: \(error.localizedDescription)")
                    case .finished:
                        print("StoryMetaService-getStories_(): Finished fetching users for gay males")
                    }
                } receiveValue: { gayMales, biMales in
                    var final: [StoryMeta] = []
                    
                    final += gayMales
                    final += biMales
                    
                    promise(.success(final))
                }
                .store(in: &self.cancellables)
                
            case .biMale:
                //Get straight women, bi women, gay men, bi men.
                Publishers.Zip4(
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "straight", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "gay", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("StoryMetaService-getStories_(): Failed to load users for bi male: \(error.localizedDescription)")
                    case .finished:
                        print("StoryMetaService-getStories_(): Finished fetching users for bi males")
                    }
                } receiveValue: { sF, bF, gM, bM in
                    var final: [StoryMeta] = []
                    
                    final += sF
                    final += bF
                    final += gM
                    final += bM
                    
                    promise(.success(final))
                }
                .store(in: &self.cancellables)
               
            case .straightFemale:
                //Get straight and bi men
                Publishers.Zip(
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "straight", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("StoryMetaService-getStories_(): Failed to load users for straight female: \(error.localizedDescription)")
                    case .finished:
                        print("StoryMetaService-getStories_(): Finished fetching users for straight female")
                    }
                } receiveValue: { sM, bM in
                    var final: [StoryMeta] = []
                    
                    final += sM
                    final += bM
                    
                    promise(.success(final))
                }
                .store(in: &self.cancellables)
                
            case .gayFemale:
                //Get gay women and bi women
                Publishers.Zip(
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "gay", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("StoryMetaService-getStories_(): Failed to load users for gay female: \(error.localizedDescription)")
                    case .finished:
                        print("StoryMetaService-getStories_(): Finished fetching users for gay female")
                    }
                } receiveValue: { gF, bF in
                    var final: [StoryMeta] = []
                    
                    final += gF
                    final += bF
        
                    promise(.success(final))
                }
                .store(in: &self.cancellables)

            case .biFemale:
                //Get straight men, bi men, gay women, bi women
                Publishers.Zip4(
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "straight", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "male", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "gay", ageMin: ageMinPref!, ageMax: ageMaxPref!),
                    self.getStories(forRadiusKM: Double(travelDistance!), forGender: "female", forSexuality: "bisexual", ageMin: ageMinPref!, ageMax: ageMaxPref!)
                )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("StoryMetaService-getStories_(): Failed to load users for bi female: \(error.localizedDescription)")
                    case .finished:
                        print("StoryMetaService-getStories_(): Finished fetching users for bi female")
                    }
                } receiveValue: { sM, bM, gF, bF in
                    var final: [StoryMeta] = []
                    
                    final += sM
                    final += bM
                    final += gF
                    final += bF
                    
                    promise(.success(final))
                }
                .store(in: &self.cancellables)

            }
        }.eraseToAnyPublisher()
    }
    
    private func getStories(forRadiusKM: Double, forGender: String, forSexuality: String, ageMin: Int, ageMax: Int) -> AnyPublisher<[StoryMeta], Error> {
        return Future<[StoryMeta], Error> { promise in
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
                return self.db.collection("Stories")
                    .order(by: "userCore.location.geoHash")
                    .start(at: [bound.startValue])
                    .end(at: [bound.endValue])
                    .whereField("userCore.gender", isEqualTo: forGender)
                    .whereField("userCore.sexuality", isEqualTo: forSexuality)
                    .limit(to: 40)
            }
            
            var results: [StoryMeta] = []
            var finished = 0
            for i in 0..<queries.count {
                self.getDocs(query: queries[i], ageMinString: ageMinString, ageMaxString: ageMaxString)
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("StoryMetaService: \(error.localizedDescription)")
                        case .finished:
                            print("StoryMetaService: Finished getting docs for query: \(String(i))")
                            finished += 1
                        }
                    } receiveValue: { users in
                        
                        print(users)
                        
                        if finished == queries.count - 1 {
                            print("StoryMetaService: results: \(results)")
                            promise(.success(results))
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    private func getDocs(query: Query, ageMinString: String, ageMaxString: String) -> AnyPublisher<[StoryMeta], Error> {
        return Future<[StoryMeta], Error> { promise in
            var results: [StoryMeta] = []
            query.getDocuments { snap, error in
                if let documents = snap?.documents {
                    print("Documents: \(documents)")
                    if documents.count == 0 {
                        promise(.success(results))
                    }
                    
                    for j in 0..<documents.count {
                        print("docs: \(documents[j].data())")
//                        let date = documents[j].data()["age"] as? String ?? ""
//                        let format = DateFormatter()
//                        format.dateFormat = "yyyy/MM/dd"
//                        let age = format.date(from: date)!
//
//                        let ageMinPref = documents[j].data()["ageMinPref"] as? Int ?? 18
//                        let ageMaxPref = documents[j].data()["ageMaxPref"] as? Int ?? 99
//                        let myAge = Int((UserCoreService.shared.currentUserCore?.age.ageString())!)
//
//                        let willingToTravel = documents[j].data()["willingToTravel"] as? Int ?? 25
//                        let lat = documents[j].data()["latitude"] as? Double ?? 0
//                        let lng = documents[j].data()["longitude"] as? Double ?? 0
//
//                        if date <= ageMinString &&
//                            date >= ageMaxString &&
//                            (((ageMinPref - 1) <= myAge! &&
//                            (ageMaxPref + 1) >= myAge!) ||
//                                ageMaxPref == myAge! ||
//                                ageMaxPref == myAge!) // Willing = 7, distance = 4
//                            && willingToTravel >= LocationService.shared.getTravelDistance(to: CLLocation(latitude: lat, longitude: lng))
//                        {
//                            let gender = documents[j].data()["gender"] as? String ?? ""
//                            let id = documents[j].data()["id"] as? String ?? ""
//                            let name = documents[j].data()["name"] as? String ?? ""
//                            let sexuality = documents[j].data()["sexuality"] as? String ?? ""
//
//                            //let uSimp = UserCore(uid: id, name: name, age: age, gender: gender, sexuality: sexuality, ageMinPref: ageMinPref, ageMaxPref: ageMaxPref, willingToTravel: willingToTravel, longitude: lng, latitude: lat)
//
//                            if id != AuthService.shared.currentUser?.uid {
//                                //results.append(uSimp)
//                            }
//                        }
                        
                        if j == (documents.count - 1){
                            promise(.success(results))
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
