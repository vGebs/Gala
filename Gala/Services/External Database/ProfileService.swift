//
//  ProfileService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

//Should i query firebase directly?: Link https://medium.com/firebase-developers/should-i-query-my-firebase-database-directly-or-use-cloud-functions-fbb3cd14118c

import Combine
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ProfileServiceProtocol {
    func createProfile(_ profile: ProfileModel, allImages: [ImageModel]) -> AnyPublisher<Void, Error>
    func getCurrentUserProfile() -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error>
    func getUserProfile(uid: String) -> AnyPublisher<(ProfileModel?, [ImageModel]?), Error>
    func updateCurrentUserProfile(profile: ProfileModel) -> AnyPublisher<Void, Error>
}

//MARK: ProfileService
//Objective:
//      To push and pull full profiles (profile text & all Profile Images) from firestore
//
class ProfileService: ProfileServiceProtocol {
    
    private let imgService: ProfileImageServiceProtocol
    private let aboutService: UserAboutServiceProtocol
    private let coreService: UserCoreServiceProtocol
    
    private var currentUID = UserService.shared.currentUser?.uid
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = ProfileService()
    private init() {
        imgService = ProfileImageService.shared
        aboutService = UserAboutService.shared
        coreService = UserCoreService.shared
    }
    
    func createProfile(_ profile: ProfileModel, allImages: [ImageModel]) -> AnyPublisher<Void, Error> {
        return createProfile_(profile, allImages: allImages)
    }
    
    func getCurrentUserProfile() -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error> {
        return getCurrentUserProfile_()
    }
    
    func getUserProfile(uid: String) -> AnyPublisher<(ProfileModel?, [ImageModel]?), Error> {
        return getUserProfile_(uid)
    }
    
    func updateCurrentUserProfile(profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return updateCurrentUserProfile_(profile)
    }

}


//MARK: - createProfile()
extension ProfileService {
    
    private func createProfile_(_ profile: ProfileModel, allImages: [ImageModel]) -> AnyPublisher<Void, Error> {
        //Call profileText & addImages
        return Future<Void, Error> { promise in
            
            self.addUserAbout(profile)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        if allImages.count == 0 {
                            promise(.success(()))
                        }
                        print("Successfully added profile text: ProfileService")
                    }
                } receiveValue: { _ in }
                .store(in: &self.cancellables)
            
            self.addUserCore(profile)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("Successfully added new user to recents")
                    }
                } receiveValue: { _ in }
                .store(in: &self.cancellables)

            if allImages.count > 0 {
                self.addImages(allImages)
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            promise(.failure(error))
                        case .finished:
                            print("Finished adding all images to Firebase: ProfileService")
                            promise(.success(()))
                        }
                    } receiveValue: { _ in }
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func addUserAbout(_ profile: ProfileModel) -> AnyPublisher<Void, Error>{
        return Future<Void, Error> { promise in
            self.aboutService.addUserAbout(profile)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .sink{ completion in
                    switch completion{
                    case let .failure(error):
                        promise(.failure(error))
                        print(error.localizedDescription)
                    case .finished:
                        print("Profile Text Successfully added to firebase: ProfileService)")
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func addUserCore(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        
        let uCore = UserCore(
            uid: profile.userID,
            name: profile.name,
            age: profile.birthday,
            gender: profile.gender,
            sexuality: profile.sexuality,
            longitude: profile.longitude,
            latitude: profile.latitude
        )
        
        return Future<Void, Error> { promise in
            self.coreService.addNewUser(core: uCore)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        promise(.success(()))
                    }
                } receiveValue: { _ in }
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func addImages(_ allImages: [ImageModel]) -> AnyPublisher<Void, Error>{
        return Future<Void, Error> { promise in
            for i in 0..<allImages.count {
                self.imgService.uploadProfileImage(img: allImages[i], name: String(i))
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .sink{ completion in
                        switch completion {
                        case let .failure(error):
                            promise(.failure(error))
                        case .finished:
                            print("Successfully added photo: ProfileViewModel(addProfileImages())")
                            if i == (allImages.count - 1){
                                promise(.success(()))
                            }
                        }
                    } receiveValue: { _ in }
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
}


//MARK: - getCurrentUserProfile()
extension ProfileService {
    private func getCurrentUserProfile_() -> AnyPublisher<(UserCore?, UserAbout?, [ImageModel]?), Error>{
        return Future<(UserCore?, UserAbout?, [ImageModel]?), Error> { promise in
            
            var core: UserCore? = nil
            var abt: UserAbout? = nil
            var imgsFinal: [ImageModel]? = nil
            
            self.getCurrentUserCore()
                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("ProfileService: Finished fetching UserCore")
                    }
                } receiveValue: { result in
                    if let coreF = result {
                        core = coreF
                        print("ProfileService: got UserCore: \(String(describing: abt))")
                    }
                }
                .store(in: &self.cancellables)

            self.getCurrentUserAbout()
                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("ProfileService: Finished fetching current UserAbout")
                    }
                } receiveValue: { result in
                    if let result = result {
                        abt = result
                        print("ProfileService: Got UserAbout: \(String(describing: abt))")
                    }
                }
                .store(in: &self.cancellables)
            
            self.getCurrentUserImages()
                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("ProfileService: Finished fetching user profile Images")
                    }
                } receiveValue: { result in
                    print("ProfileService: Result from getCurrentUserImages: \(String(describing: result))")
                    if let imgs = result {
                        imgsFinal = imgs
                        print("ProfileService: Got imgs: \(String(describing: imgsFinal))")
                        
                        promise(.success((core, abt, imgsFinal)))
                        
                    }
                }
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func getCurrentUserCore() -> AnyPublisher<UserCore?, Error> {
        return coreService.getCurrentUserCore()
    }
    
    private func getCurrentUserAbout() -> AnyPublisher<UserAbout?, Error> {
        return aboutService.getCurrentUserAbout()
    }
    
    private func getCurrentUserImages() -> AnyPublisher<[ImageModel]?, Error> {
        return Future<[ImageModel]?, Error> { promise in
            var profileImgs: [ImageModel]? = nil
            var imgsRecieved = 0
            var imgsNotFound = 0
            for i in 0..<7 {
                ProfileImageService.shared.getProfileImage(id: self.currentUID!, index: String(i))
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion{
                        case let .failure(error):
                            //promise(.failure(error))
                            print("ProfileService non lethal error: \(error.localizedDescription)")
                        case .finished:
                            print("getting images from firebase: ProfileService")
                        }
                    } receiveValue: { img in
                        if let img = img {
                            print("image coming from firebase: \(img)")
                            let image = ImageModel(image: img)
                            //profileImgs?.insert(image, at: i)
                            if profileImgs == nil {
                                let tempArr = [image]
                                profileImgs = tempArr
                                imgsRecieved += 1
                                print("img received: \(imgsRecieved)")
                            } else {
                                profileImgs?.append(image)
                                imgsRecieved += 1
                                print("img received: \(imgsRecieved)")
                            }
                            print("Describing profile images: \(String(describing: profileImgs))")
                        } else {
                            print("no image found")
                            imgsNotFound += 1
                            print("img not received: \(imgsNotFound)")
                        }
                        
                        if (imgsRecieved + imgsNotFound) == 7 {
                            print("total search for images: \(imgsRecieved + imgsNotFound)")
                            promise(.success(profileImgs))
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
}

extension ProfileService {
    private func getUserProfile_(_ uid: String) -> AnyPublisher<(ProfileModel?, [ImageModel]?), Error> {
        return Future<(ProfileModel?, [ImageModel]?), Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}

//MARK: - updateCurrentUserProfile()

extension ProfileService {
    func updateCurrentUserProfile_(_ profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}
