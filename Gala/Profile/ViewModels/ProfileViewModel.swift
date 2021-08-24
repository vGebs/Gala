//
//  ProfileViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import SwiftUI

//Check for user input:
//Check for Profile pic, if not add to warning message
//Check for bio input, if not add to warning message
//check for images, if not add to warning message
//check for job, if nil add to warning
//check for school, if nil
//Check for user gender, if nil can not continue
//Ask for sexuality, straight is default

final class ProfileViewModel: ObservableObject {
    
//MARK: - General Purpose Variables
        
    private let profileManager = ProfilePersistenceService()
    private var userService: AuthServiceProtocol = AuthService.shared
    
    private var cancellables: [AnyCancellable] = []
    
    private(set) var nameText: String
    private(set) var cityText: String = LocationService.shared.city
    private(set) var countryText: String = LocationService.shared.country
    private(set) var ageText: String
    private var age: Date
    private var email: String
    private(set) var title = "Create your profile"
    private(set) var subtitle = "Let's get started"
    @Published var bioHeader: String  = "Tell us about yourself"
    @Published var pictureHeader: String = "Showcase images"
    private(set) var chooseGenderHeader = "Select your gender"
    private(set) var chooseSexualityHeader = "Select your sexuality"
    @Published var jobHeader = "What do you do for a living?"
    @Published var schoolHeader = "Where have you studied?"
    private(set) var submitButtonText = "Submit!"
    
    @ObservedObject var slider = CustomSlider(start: 18, end: 99)
    
    private(set) var maxBioCharCount = 150
    
    @Published var editPressed = false
    
    @Published var profileImage: [ImageModel] = []
    @Published var oneProfilePic: Int = 1
    
    @Published var bioText = ""
    @Published var bioCharCount = 0
    
    @Published var images: [ImageModel] = []
    @Published var maxImages: Int = 6
    
    @Published var presentProfileImagePicker = false
    @Published var presentCropProfilePic = false
    @Published var presentImageCropper = false
    
    @Published var presentImageCropperWithIndex = -1
    
    @Published var showAddImages = false
    @Published var showCropper = false
        
    @Published var currentImageDrag: ImageModel?
        
    @Published var activeSheet: ActiveSheet?
    
    @Published var jobText = ""
    @Published var schoolText = ""
    
    @Published var selectGenderDropDownText: Gender = .select
    @Published var selectSexualityDropDownText: Sexuality = .select

    @Published var genderIsReady = false
    @Published var sexualityIsReady = false
    
    private(set) var genderWarning = "Enter your gender to continue. *editable*"
    private(set) var sexualityWarning = "Enter your sexuality to continue. *editable*"
    
    var isValid: Bool {
        genderIsReady && sexualityIsReady
    }
    
    @Published var showBio = true
    @Published var showImages = true
    @Published var showJob = true
    @Published var showSchool = true
    @Published var showGender = false
    @Published var showSexuality = false
    
    @Published var submitPressed = false
    
    @Published var loading = false
    
    var mode: Mode
    
//MARK: - Enums
    enum Mode{
        case createAccount
        case profileStandard
    }
    
    enum Gender: String {
        case select
        case male
        case female
    }
    
    enum Sexuality: String {
        case select
        case straight
        case gay
        case bisexual
    }
    
//MARK: - Initializer
    
    deinit {
        print("ProfileViewModel = nil")
        
        for i in 0..<profileImage.count {
            profileImage.remove(at: i)
        }
        
        for i in 0..<images.count {
            images.remove(at: i)
        }
    }
    
    //Add email to initializer so I can make the profileModel
    //Add default initializers so that we dont have to enter a name, age, or email when using .profileStandard
    init(
        name: String = String(),
        age: Date = Date(),
        email: String = String(),
        mode: Mode
    ){
        
//        self.nameText = name
//        self.age = age
//        self.ageText = age.ageString()
//        self.email = email
        
        self.mode = mode
        
        switch mode {
        case .createAccount:
            //creat new user in cd and fb
            self.nameText = name
            self.age = age
            self.ageText = age.ageString()
            self.email = email

        case .profileStandard:
            //PullData from CD, if nothing returns, get from firebase
            self.nameText = name
            self.age = age
            self.ageText = age.ageString()
            self.email = email
            
            guard let currentUser = userService.currentUser?.uid else { return }
            
            //if !self.readProfileFromCoreData(id: currentUser) {
                self.readProfileFromFirebase(uid: currentUser)
               // print("could not get core data")
            //}
        }
        
        $bioCharCount
            .flatMap { count -> AnyPublisher<String, Never> in
                if count > self.maxBioCharCount {
                    let newBio = self.bioText.dropLast()
                    return Just(String(newBio)).eraseToAnyPublisher()
                } else {
                    let newBio = self.bioText
                    return Just(String(newBio)).eraseToAnyPublisher()
                }
            }
            .assign(to: &$bioText)
        
        $images
            .flatMap { images -> AnyPublisher<Int, Never> in
                if images.count == 6 {
                    return Just(Int(0)).eraseToAnyPublisher()
                } else if images.count == 5 {
                    return Just(1).eraseToAnyPublisher()
                } else if images.count == 4 {
                    return Just(2).eraseToAnyPublisher()
                } else if images.count == 3 {
                    return Just(3).eraseToAnyPublisher()
                } else if images.count == 2 {
                    return Just(4).eraseToAnyPublisher()
                } else if images.count == 1 {
                    return Just(5).eraseToAnyPublisher()
                } else {
                    return Just(6).eraseToAnyPublisher()
                }
            }.assign(to: &$maxImages)
        
        $selectGenderDropDownText
            .flatMap{ gender -> AnyPublisher<Bool, Never> in
                return self.checkGender(gender)
            }
            .assign(to: &$genderIsReady)
        
        $selectSexualityDropDownText
            .flatMap { sexuality -> AnyPublisher<Bool, Never> in
                return self.checkSexuality(sexuality)
            }
            .assign(to: &$sexualityIsReady)

        $bioCharCount
            .flatMap { num -> AnyPublisher<Bool, Never> in
                if num == 0 {
                    return Just(false).eraseToAnyPublisher()
                } else {
                    return Just(true).eraseToAnyPublisher()
                }
            }
            .assign(to: &$showBio)
        
        $images
            .flatMap { images -> AnyPublisher<Bool, Never> in
                if images.count == 0 {
                    return Just(false).eraseToAnyPublisher()
                } else {
                    return Just(true).eraseToAnyPublisher()
                }
            }
            .assign(to: &$showImages)
        
        $jobText
            .flatMap{ text -> AnyPublisher<Bool, Never> in
                if text == "" {
                    return Just(false).eraseToAnyPublisher()
                } else {
                    return Just(true).eraseToAnyPublisher()
                }
            }
            .assign(to: &$showJob)
        
        $schoolText
            .flatMap{ text -> AnyPublisher<Bool, Never> in
                if text == "" {
                    return Just(false).eraseToAnyPublisher()
                } else {
                    return Just(true).eraseToAnyPublisher()
                }
            }
            .assign(to: &$showSchool)
        
        $editPressed
            .flatMap { pressed -> AnyPublisher<String, Never> in
                if pressed == true || self.mode == .createAccount {
                    return Just("Tell us about yourself").eraseToAnyPublisher()
                } else {
                    return Just("A little bit about me").eraseToAnyPublisher()
                }
            }
            .assign(to: &$bioHeader)
        
        $editPressed
            .flatMap { pressed -> AnyPublisher<String, Never> in
                if pressed == true || self.mode == .createAccount{
                    return Just("Let's see your best looks").eraseToAnyPublisher()
                } else {
                    return Just("Best moments").eraseToAnyPublisher()
                }
            }
            .assign(to: &$pictureHeader)
        
        $editPressed
            .flatMap { pressed -> AnyPublisher<String, Never> in
                if pressed == true || self.mode == .createAccount {
                    return Just("What do you do for a living?").eraseToAnyPublisher()
                } else {
                    if self.checkForVowel(self.jobText){
                        return Just("I'm an").eraseToAnyPublisher()
                    } else {
                        return Just("I'm a").eraseToAnyPublisher()
                    }
                }
            }
            .assign(to: &$jobHeader)
        
        $editPressed
            .flatMap { bool -> AnyPublisher<String, Never> in
                if bool == true || self.mode == .createAccount {
                    return Just("Where did you go to school?").eraseToAnyPublisher()
                } else {
                    return Just("I went to").eraseToAnyPublisher()
                }
            }
            .assign(to: &$schoolHeader)
    }
    
//MARK: - Public Methods ------------------------------------------------------------------------------------->
    
    enum ActionMode {
        case createProfile
        case submitProfileChanges
    }
    
    public func actionPressed(_ mode: ActionMode) {
        switch mode {
        case .createProfile:
            self.createProfile()
            print("Created profile")
            
        case .submitProfileChanges:
            
            print("Profile changed")
        }
    }
    
//    public func toggleDarkMode() {
//        isDarkMode.toggle()
//    }
    
    public func logout(){
        self.userService.logout()
            .sink{ completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    print("Succesfully logged out")
                    UserDefaults.standard.set(false, forKey: "loggedIn")
                    UserDefaults.standard.set("", forKey: "email")
                    UserDefaults.standard.set("", forKey: "password")
                    AppState.shared.allowAccess = false
                    AppState.shared.onLandingPage = true
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

//MARK: - Image options ------------------------------------------------------------------------------------->
//NOTE: Make a image container class that deals with the sorting of images based on some ID
extension ProfileViewModel {
    public func getImageItem(at i: Int) -> UIImage?{
        if images.count > i {
            return images[i].image
        } else {
            return nil
        }
    }
    
    public func removePicture(at i: Int){
        if images.count > i {
            images.remove(at: i)
        }
    }
    
    public func getProfilePic() -> UIImage?{
        if profileImage.count == 1 {
            return profileImage[0].image
        } else {
            return nil
        }
    }
    
    public func removeProfilePic() {
        if profileImage.count == 1 {
            profileImage.remove(at: 0)
        }
    }
}

//MARK: - Data Push & Pull ------------------------------------------------------------------------------------->
extension ProfileViewModel {
    
    private func createProfile() {
        self.loading = true
        pushProfile()
    }
    
    private func pushProfile() {
        var bio = ""
        var job = ""
        var school = ""
        
        if bioText != "" {
            bio = bioText
        }
        
        if jobText != "" {
            job = jobText
        }
        
        if schoolText != "" {
            school = schoolText
        }
        
        guard let currentUser = userService.currentUser?.uid else { return }
        
        let profile = ProfileModel(
            name: nameText,
            birthday: age,
            latitude: LocationService.shared.coordinates.latitude,
            longitude: LocationService.shared.coordinates.longitude,
            userID: currentUser,
            bio: bio,
            gender: selectGenderDropDownText.rawValue,
            sexuality: selectSexualityDropDownText.rawValue,
            ageMinPref: Int(min(slider.lowHandle.currentValue, slider.highHandle.currentValue)),
            ageMaxPref: Int(max(slider.lowHandle.currentValue, slider.highHandle.currentValue)),
            job: job,
            school: school
        )

        let allImgs = profileImage + images
        
        //Create Firebase Profile
        pushProfileFirestore(profile, allImgs)
        //pushProfileToCoreData(profile, allImgs)
    }
    
    private func pushProfileFirestore(_ profile: ProfileModel, _ imgs: [ImageModel]) {
        ProfileService.shared.createProfile(profile, allImages: imgs)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                switch completion{
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    print("Profile Successfully added to firebase: ProfileViewModel")
                    self.loading = false
                    AppState.shared.allowAccess = true
                    AppState.shared.createAccountPressed = false
                    self.submitPressed = true
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func pushProfileToCoreData(_ profile: ProfileModel, _ imgs: [ImageModel]) {
        profileManager.createProfile(profile, images: imgs)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Could not create Core Data profile: \(error.localizedDescription)")
                case .finished:
                    print("Finished creating Core Data Profile")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func readProfileFromCoreData(id: String) -> Bool {
        
        var returnedNil = false
        
        profileManager.fetchProfile(id: id)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished fetching profile from Core Data: ProfileViewModel")
                }
            } receiveValue: { text, mainImgs, sideImgs in
                if text == nil || mainImgs == nil || sideImgs == nil {
                    returnedNil = true
                } else {
                    //Populate UI w/ text
                    self.nameText = text!.name
                    self.age = text!.birthday
                    self.ageText = self.age.ageString()
                    
                    if let bio = text?.bio {
                        self.bioText = bio
                    }
                    
                    if text?.gender == "male" || text?.gender == "Male" {
                        self.selectGenderDropDownText = .male
                    } else {
                        self.selectGenderDropDownText = .female
                    }
                    
                    if text?.sexuality == "gay" || text?.sexuality == "Gay"{
                        self.selectSexualityDropDownText = .gay
                    } else if text?.sexuality == "Straight" || text?.sexuality == "straight" {
                        self.selectSexualityDropDownText = .straight
                    } else {
                        self.selectSexualityDropDownText = .bisexual
                    }
                    
                    if let job = text?.job {
                        self.jobText = job
                    }
                    
                    if let school = text?.school {
                        self.schoolText = school
                    }
                    
                    //Populate UI w/ mainImg
                    if let main = mainImgs {
                        self.profileImage += main
                    }
                    
                    //Populate UI w/ sideImgs
                    if let side = sideImgs {
                        self.images += side
                    }
                }
            }
            .store(in: &self.cancellables)

        if returnedNil {
            return false
        } else {
            return true
        }
    }
    
    private func readProfileFromFirebase(uid: String) {
        
        ProfileService.shared.getCurrentUserProfile()
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    print("getting profile from firebase: ProfileViewModel")
                }
            } receiveValue: { core, abt, imgs in

                if let core = core {
                    //Assign Core profile to UserService
                    
                    self.age = core.age
                    self.ageText = self.age.ageString()
                    self.nameText = core.name
                    self.selectGenderDropDownText = "male" == core.gender || "Male" == core.gender ? .male : .female
                    
                    if core.sexuality == "Gay" || core.sexuality == "gay" {
                        self.selectSexualityDropDownText = .gay
                    } else if core.sexuality == "Straight" || core.sexuality == "straight" {
                        self.selectSexualityDropDownText = .straight
                    } else {
                        self.selectSexualityDropDownText = .bisexual
                    }
                    
                    let ageMin = 18
                    let ageMax = 99
                    
                    let range = ageMax - ageMin
                    let ageMinPrefPercent = Double((core.ageMinPref - ageMin)) / Double(range)
                    let ageMaxPrefPercent = Double((core.ageMaxPref - ageMin)) / Double(range)
                        
                    self.slider.lowHandle.currentPercentage = SliderValue(wrappedValue: ageMinPrefPercent)
                    self.slider.highHandle.currentPercentage = SliderValue(wrappedValue: ageMaxPrefPercent)
                                        
                    self.slider.lowHandle.currentLocation = CGPoint(x: (CGFloat(ageMinPrefPercent)/1.0) *        self.slider.lowHandle.sliderWidth, y: self.slider.lowHandle.sliderHeight / 2)
                    self.slider.highHandle.currentLocation = CGPoint(x: (CGFloat(ageMaxPrefPercent)/1.0) * self.slider.highHandle.sliderWidth, y: self.slider.highHandle.sliderHeight / 2)
                }
                
                if let abt = abt {
                    self.bioText = abt.bio ?? ""
                    self.jobText = abt.job ?? ""
                    self.schoolText = abt.school ?? ""
                }
                
                if let imgs = imgs {
                    self.profileImage.append(imgs[0])
                    
                    for i in 1 ..< imgs.count {
                        self.images.append(imgs[i])
                    }
                }
            }
            .store(in: &cancellables)
    }
}

//MARK: - Validation ------------------------------------------------------------------------------------->
extension ProfileViewModel {
    private func checkForVowel(_ text: String) -> Bool {
        
        if let first = text.first {
            if first == "a" || first == "e" || first == "i" || first == "o" || first == "y" {
                return true
            } else if first == "A" || first == "E" || first == "I" || first == "O" || first == "U" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    private func checkGender(_ gender: Gender) -> AnyPublisher<Bool,Never> {
        switch gender {
        case .male:
            return Just(true).eraseToAnyPublisher()
        case .female:
            return Just(true).eraseToAnyPublisher()
        case .select:
            return Just(false).eraseToAnyPublisher()
        }
    }
    
    private func checkSexuality(_ sexuality: Sexuality) -> AnyPublisher<Bool, Never> {
        switch sexuality{
        case .select:
            return Just(false).eraseToAnyPublisher()
        case .straight:
            return Just(true).eraseToAnyPublisher()
        case .gay:
            return Just(true).eraseToAnyPublisher()
        case .bisexual:
            return Just(true).eraseToAnyPublisher()
        }
    }
}
