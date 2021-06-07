//
//  ProfileManager.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import CoreData
import SwiftUI
import AVFoundation

//Core data MVVM Style: https://www.youtube.com/watch?v=BPQkpxtgalY&t=850s

protocol ProfilePersistenceProtocol {
    func createProfile(_ profile: ProfileModel, images: [ImageModel]) -> AnyPublisher<Void, Error>
    func fetchProfile(id: String) -> AnyPublisher<(ProfileModel?, [ImageModel]?, [ImageModel]?), Never>
    func updateProfile(id: String) -> AnyPublisher<Void, Error>
    func deleteProfile(id: String) -> AnyPublisher<Void, Error>
}

class ProfileManager: ObservableObject, ProfilePersistenceProtocol {
    
    //static let shared = ProfileManager()
    
    private let container: NSPersistentContainer
    
    @Published private var profiles: [ProfileEntity] = []
    @Published private var mainImages: [ProfileMainImgEntity] = []
    @Published private var sideImages: [ProfileSideImgEntity] = []
        
    private var cancellables: [AnyCancellable] = []
    
    init() {
        container = NSPersistentContainer(name: "GalaPersistence")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Could not load local data: \(error.localizedDescription)")
            } else {
                self.fetchProfiles()
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .receive(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("Failed to fetch profiles: \(error.localizedDescription)")
                        case .finished:
                            print("Successfully completed fetching profiles: Core Data")
                        }
                    } receiveValue: { profiles in
                        self.profiles = profiles
                    }
                    .store(in: &self.cancellables)

                self.fetchProfileMainImages()
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .receive(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("Failed to fetch main images from Core Data: \(error.localizedDescription)")
                        case .finished:
                            print("Successfully completed fetching main images from Core Data")
                        }
                    } receiveValue: { main in
                        self.mainImages = main
                    }
                    .store(in: &self.cancellables)
                
                self.fetchProfileSideImages()
                    .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                    .receive(on: DispatchQueue.global(qos: .userInteractive))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("Failed to fetch side images from Core Data: \(error.localizedDescription)")
                        case .finished:
                            print("Successfully completed fetching side images from Core Data")
                        }
                    } receiveValue: { side in
                        self.sideImages = side
                    }
                    .store(in: &self.cancellables)
            }
        }
    }
    
    private func saveData() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try self.container.viewContext.save()
                self.fetchProfiles()
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .receive(on: DispatchQueue.global(qos: .userInitiated))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("Failed to fetch profiles: \(error.localizedDescription)")
                        case .finished:
                            print("Finished fetching profiles")
                        }
                    } receiveValue: { profiles in
                        self.profiles = profiles
                    }
                    .store(in: &self.cancellables)

                self.fetchProfileMainImages()
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .receive(on: DispatchQueue.global(qos: .userInitiated))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("Failed to fetch main images from Core Data: \(error.localizedDescription)")
                        case .finished:
                            print("Finished fetching main images from Core Data")
                        }
                    } receiveValue: { main in
                        self.mainImages = main
                    }
                    .store(in: &self.cancellables)

                self.fetchProfileSideImages()
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .receive(on: DispatchQueue.global(qos: .userInitiated))
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("Failed to fetch side images from Core Data: \(error.localizedDescription)")
                        case .finished:
                            print("Finished fetching side images from Core Data")
                        }
                    } receiveValue: { side in
                        self.sideImages = side
                    }
                    .store(in: &self.cancellables)
                
                promise(.success(()))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}



//MARK: - CRUD
extension ProfileManager {
    
    func createProfile(_ profile: ProfileModel, images: [ImageModel]) -> AnyPublisher<Void, Error>{
        return Future<Void, Error> { promise in
            var textValid = false
            var mainImgValid = false
            var sideImgsValid = false
            
            self.addTextualElements(profile: profile)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.global(qos: .userInitiated))
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("Unable to store textual elements to core data: ProfileManager: \(error.localizedDescription)")
                        promise(.failure(error))
                    case .finished:
                        print("Successfully stored textual elements to core data: ProfileManager")
                        textValid = true
                    }
                } receiveValue: { _ in }
                .store(in: &self.cancellables)

            
            for i in 0..<images.count {
                if i == 0 {
                    self.addMainImage(img: images[i], id: UserService.shared.currentUser!.uid)
                        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                        .receive(on: DispatchQueue.global(qos: .userInitiated))
                        .sink { completion in
                            switch completion {
                            case .failure(let error):
                                print("Failed to save main image into Core Data: ProfileManager: \(error.localizedDescription)")
                                promise(.failure(error))
                            case .finished:
                                print("Finished saving image to Core Data: ProfileManager")
                                mainImgValid = true
                            }
                        } receiveValue: { _ in }
                        .store(in: &self.cancellables)
                } else {
                    self.addSideImage(img: images[i], id: UserService.shared.currentUser!.uid)
                        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                        .receive(on: DispatchQueue.global(qos: .userInitiated))
                        .sink { completion in
                            switch completion {
                            case .failure(let error):
                                print("Failed to save side image into Core Data: ProfileManager: \(error.localizedDescription)")
                                promise(.failure(error))
                            case .finished:
                                print("Finished saving side image to Core Data: ProfileManager")
                                if i == (images.count - 1) {
                                    sideImgsValid = true
                                }
                            }
                        } receiveValue: { _ in }
                        .store(in: &self.cancellables)
                }
            }
            
            if textValid && mainImgValid && sideImgsValid {
                promise(.success(()))
            }
            
        }.eraseToAnyPublisher()
    }
    
    func fetchProfile(id: String) -> AnyPublisher<(ProfileModel?, [ImageModel]?, [ImageModel]?), Never> {
        return Future<(ProfileModel?, [ImageModel]?, [ImageModel]?), Never>{ promise in
            var profileText: ProfileModel = ProfileModel(name: "", birthday: Date(), location: "", id: "", bio: "", gender: "", sexuality: "", job: "", school: "")
            var mainImages: [ImageModel] = []
            var sideImages: [ImageModel] = []
            
            self.fetchProfileTextWith(id: id)
                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                .receive(on: DispatchQueue.global(qos: .userInteractive))
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Finished fetching profile text with ID: \(id): ProfileManager")
                    }
                } receiveValue: { profile in
                    if let profile = profile {
                        profileText = profile
                    }
                }.store(in: &self.cancellables)
            
            self.fetchMainImagesWith(id: id)
                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                .receive(on: DispatchQueue.global(qos: .userInteractive))
                .sink { completion in
                    switch completion{
                    case .finished:
                        print("Finished fetching main images from Core Data with ID: \(id): ProfileManager")
                    }
                } receiveValue: { mainImgs in
                    if let imgs = mainImgs {
                        mainImages += imgs
                    }
                }
                .store(in: &self.cancellables)

            self.fetchSideImagesWith(id: id)
                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                .receive(on: DispatchQueue.global(qos: .userInteractive))
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Finished fetching side images from Core Data with ID: \(id): ProfileManager")
                    }
                } receiveValue: { sideImgs in
                    if let side = sideImgs {
                        sideImages += side
                    }
                }
                .store(in: &self.cancellables)
            
            var textValid = false
            var mainValid = false
            var sideValid = false

            if profileText.name != "" {
                textValid = true
            }
            
            if mainImages.count > 0 {
                mainValid = true
            }
            
            if sideImages.count > 0 {
                sideValid = true
            }
            
            if textValid && mainValid && sideValid {
                promise(.success((profileText, mainImages, sideImages)))
                
            } else if !textValid && mainValid && sideValid {
                promise(.success((nil, mainImages, sideImages)))
                
            } else if textValid && !mainValid && sideValid {
                promise(.success((profileText, nil, sideImages)))
                
            } else if textValid && mainValid && !sideValid {
                promise(.success((profileText, mainImages, nil)))
                
            } else if !textValid && !mainValid && sideValid {
                promise(.success((nil, nil, sideImages)))
                
            } else if !textValid && mainValid && !sideValid {
                promise(.success((nil, mainImages, nil)))
                
            } else if textValid && !mainValid && !sideValid {
                promise(.success((profileText, nil, nil)))
                
            } else if !textValid && !mainValid && !sideValid {
                promise(.success((nil, nil, nil)))
            }
            
        }.eraseToAnyPublisher()
    }
    
    func updateProfile(id: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
    
    func deleteProfile(id: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            
        }.eraseToAnyPublisher()
    }
}



//MARK: - Helpers
extension ProfileManager {
    
    private func addTextualElements(profile: ProfileModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let newProfile = ProfileEntity(context: self.container.viewContext)
            
            newProfile.name = profile.name
            newProfile.id = profile.id
            newProfile.birthday = profile.birthday
            newProfile.gender = profile.gender
            newProfile.sexuality = profile.sexuality
            newProfile.bio = profile.bio ?? ""
            newProfile.job = profile.job ?? ""
            newProfile.school = profile.school ?? ""
            
            self.saveData()
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.global(qos: .userInitiated))
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
    
    private func addMainImage(img: ImageModel, id: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let new = ProfileMainImgEntity(context: self.container.viewContext)
            
            //Compress img
            let compress = img.image.jpegData(compressionQuality: compressionQuality)!

            //Store img
            new.profilePic = compress
            new.id = id
            
            self.saveData()
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.global(qos: .userInitiated))
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
    
    private func addSideImage(img: ImageModel, id: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error>{ promise in
            let new = ProfileSideImgEntity(context: self.container.viewContext)
            
            //Compress img
            let compress = img.image.jpegData(compressionQuality: compressionQuality)!
            
            //Store img
            new.img = compress
            new.id = id
            
            self.saveData()
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.global(qos: .userInitiated))
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
    
    private func fetchProfiles() -> AnyPublisher<[ProfileEntity], Error> {
        return Future<[ProfileEntity], Error> { promise in
            let request = NSFetchRequest<ProfileEntity>(entityName: "ProfileEntity")
            
            do {
                let profiles = try self.container.viewContext.fetch(request)
                promise(.success(profiles))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    private func fetchProfileMainImages() -> AnyPublisher<[ProfileMainImgEntity], Error> {
        return Future<[ProfileMainImgEntity], Error> { promise in
            let request = NSFetchRequest<ProfileMainImgEntity>(entityName: "ProfileMainImgEntity")
            
            do {
                let mainImages = try self.container.viewContext.fetch(request)
                promise(.success(mainImages))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    private func fetchProfileSideImages() -> AnyPublisher<[ProfileSideImgEntity], Error> {
        return Future<[ProfileSideImgEntity], Error> { promise in
            let request = NSFetchRequest<ProfileSideImgEntity>(entityName: "ProfileSideImgEntity")
            
            do {
                let sideImages = try self.container.viewContext.fetch(request)
                promise(.success(sideImages))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    private func fetchProfileTextWith(id: String) -> AnyPublisher<ProfileModel?, Never> {
        return Future<ProfileModel?, Never> { promise in
            for profile in self.profiles{
                if profile.id == id {
                    let prof = ProfileModel(name: profile.name ?? "", birthday: profile.birthday ?? Date(), location: profile.location ?? "", id: profile.id ?? "", bio: profile.bio ?? "", gender: profile.gender ?? "", sexuality: profile.sexuality ?? "", job: profile.job ?? "", school: profile.school ?? "")
                    promise(.success(prof))
                }
            }
            promise(.success(nil))
        }.eraseToAnyPublisher()
    }
    
    private func fetchMainImagesWith(id: String) -> AnyPublisher<[ImageModel]?, Never> {
        return Future<[ImageModel]?, Never> { promise in
            var arr: [ImageModel] = []
            for imageProfile in self.mainImages {
                if imageProfile.id == id {
                    if let profilePicData = imageProfile.profilePic {
                        if let img = UIImage(data: profilePicData){
                            let imgM = ImageModel(image: img)
                            arr.append(imgM)
                            promise(.success(arr))
                        }
                    }
                }
            }
            promise(.success(nil))
        }.eraseToAnyPublisher()
    }
    
    private func fetchSideImagesWith(id: String) -> AnyPublisher<[ImageModel]?, Never> {
        return Future<[ImageModel]?, Never> { promise in
            var arr: [ImageModel] = []
            for img in self.sideImages {
                if img.id == id {
                    if let sideImgData = img.img {
                        if let unCompressed = UIImage(data: sideImgData){
                            let imgModel = ImageModel(image: unCompressed)
                            arr.append(imgModel)
                        }
                    }
                }
            }
            
            if arr.count > 0 {
                promise(.success(arr))
            } else {
                promise(.success(nil))
            }
        }.eraseToAnyPublisher()
    }
}
