//
//  ProfileService.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ProfileServiceProtocol {
    func createProfile(_ profile: ProfileModel, allImages: [ImageModel]) -> AnyPublisher<Void, Error>
    func getCurrentUserProfile() -> AnyPublisher<(ProfileModel?, [ImageModel]?), Error>
    func getUserProfile(uid: String) -> AnyPublisher<(ProfileModel?, [ImageModel]?), Error>
}

//MARK: ProfileService
//Objective:
//      To push and pull full profiles (profile text & all Profile Images) from firestore
//
class ProfileService: ProfileServiceProtocol {
    
    private var imgService: ProfileImageService
    private var profileTextService: ProfileTextService
    
    private var cancellables: [AnyCancellable] = []
    
    static let shared = ProfileService()
    private init() {
        imgService = ProfileImageService.shared
        profileTextService = ProfileTextService.shared
    }
    
    func createProfile(_ profile: ProfileModel, allImages: [ImageModel]) -> AnyPublisher<Void, Error> {
        return createProfile_(profile, allImages: allImages)
    }
    
    func getCurrentUserProfile() -> AnyPublisher<(ProfileModel?, [ImageModel]?), Error> {
        return getCurrentUserProfile_()
    }
    
    func getUserProfile(uid: String) -> AnyPublisher<(ProfileModel?, [ImageModel]?), Error> {
        return getUserProfile_(uid)
    }
}


//MARK: - createProfile()
extension ProfileService {
    
    private func createProfile_(_ profile: ProfileModel, allImages: [ImageModel]) -> AnyPublisher<Void, Error> {
        //Call profileText & addImages
        return Future<Void, Error> { promise in
            
//            var textAdded = false
//            var imgsAdded = false
            
            self.addText(profile)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("Successfully added profile text: ProfileService")
                    }
                } receiveValue: { _ in }
                .store(in: &self.cancellables)
            
            self.addImages(allImages)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("Finished adding all images to Firebase: ProfileService")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            promise(.success(()))
                        }
                    }
                } receiveValue: { _ in }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private func addText(_ profile: ProfileModel) -> AnyPublisher<Void, Error>{
        return Future<Void, Error> { promise in
            self.profileTextService.addProfileText(profile)
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
    private func getCurrentUserProfile_() -> AnyPublisher<(ProfileModel?, [ImageModel]?), Error>{
        return Future<(ProfileModel?, [ImageModel]?), Error > { promise in
            
            var profileFinal: ProfileModel? = nil
            var imgsFinal: [ImageModel]? = nil
            
            self.getCurrentUserText()
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("Finished fetching current user profile text: ProfileService")
                    }
                } receiveValue: { result in
                    if let profile = result {
                        profileFinal = profile
                        print("ProfileService getting text (profileFinal): \(String(describing: profileFinal))")
                    }
                }
                .store(in: &self.cancellables)
            
            self.getCurrentUserImages()
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("Finished fetching user profile Images: ProfileService")
                    }
                } receiveValue: { result in
                    print("Result from getCurrentUserImages: \(String(describing: result))")
                    if let imgs = result {
                        imgsFinal = imgs
                        print("ProfileService getting imgs (imgsFinal): \(String(describing: imgsFinal))")
                        promise(.success((profileFinal, imgsFinal)))
                    } else {
                        promise(.success((profileFinal, nil)))
                    }
                }
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    private func getCurrentUserText() -> AnyPublisher<ProfileModel?, Error> {
        return profileTextService.getCurrentUserProfileText()
    }
    
    private func getCurrentUserImages() -> AnyPublisher<[ImageModel]?, Error> {
        return Future<[ImageModel]?, Error> { promise in
            var profileImgs: [ImageModel]? = nil
            var imgsRecieved = 0
            var imgsNotFound = 0
            for i in 0..<7 {
                ProfileImageService.shared.getProfileImage(name: String(i))
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
