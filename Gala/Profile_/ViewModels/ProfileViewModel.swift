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
        
    //@Published var dropDownViewModel: MyStoriesDropDownViewModel
    
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
    
    @Published var doubleKnobSlider = CustomSlider(start: 18, end: 99, doubleKnob: true)
    @Published var singleKnobSlider = CustomSlider(start: 1, end: 250, doubleKnob: false)
    
    private(set) var maxBioCharCount = 150
    
    @Published var editPressed = false
    
    //@Published var showStories = StoryService.shared.postIDs.count > 0 ? true : false
    
    @Published var dropDownVM = MyStoriesDropDownViewModel()
    @Published var newComerLikesVM = BasicLikesViewModel()
        
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
    
    @Published var aboutChanged = false
    @Published var coreChanged = false
    @Published var profileImgChanged = false 
    @Published var imgsChanged = false 
    
    var mode: Mode
    
//MARK: - Enums
    enum Mode{
        case createAccount
        case profileStandard
        case otherAccount
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
        print("ProfileViewModel: Deinitializing")
        
        profileImage.removeAll()
        images.removeAll()
        cancellables.removeAll()
    }
    
    //Add email to initializer so I can make the profileModel
    //Add default initializers so that we dont have to enter a name, age, or email when using .profileStandard
    init(
        name: String = String(),
        age: Date = Date(),
        email: String = String(),
        mode: Mode,
        uid: String?
    ){
                
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
            
            //guard let currentUser = userService.currentUser?.uid else { return }
            if let uid = uid {
                //if !self.readProfileFromCoreData(id: currentUser) {
                    self.readProfileFromFirebase(uid: uid)
                   // print("could not get core data")
                //}
            }
        case .otherAccount:
            self.nameText = name
            self.age = age
            self.ageText = age.ageString()
            self.email = email
            
            if let uid = uid {
                self.readProfileFromFirebase(uid: uid)
            }
        }
        
        $bioCharCount
            .flatMap { [weak self] count -> AnyPublisher<String, Never> in
                if count > self!.maxBioCharCount {
                    let newBio = self!.bioText.dropLast()
                    return Just(String(newBio)).eraseToAnyPublisher()
                } else {
                    let newBio = self!.bioText
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
            .flatMap{ [weak self] gender -> AnyPublisher<Bool, Never> in
                return self!.checkGender(gender)
            }
            .assign(to: &$genderIsReady)
        
        $selectSexualityDropDownText
            .flatMap { [weak self] sexuality -> AnyPublisher<Bool, Never> in
                return self!.checkSexuality(sexuality)
            }
            .assign(to: &$sexualityIsReady)

        $bioText
            .flatMap { text -> AnyPublisher<Bool, Never> in
                if text == "" {
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
            .flatMap { [weak self] pressed -> AnyPublisher<String, Never> in
                if pressed == true || self!.mode == .createAccount {
                    return Just("Tell us about yourself").eraseToAnyPublisher()
                } else {
                    return Just("A little bit about me").eraseToAnyPublisher()
                }
            }
            .assign(to: &$bioHeader)
        
        $editPressed
            .flatMap { [weak self] pressed -> AnyPublisher<String, Never> in
                if pressed == true || self!.mode == .createAccount{
                    return Just("Let's see your best looks").eraseToAnyPublisher()
                } else {
                    return Just("Best moments").eraseToAnyPublisher()
                }
            }
            .assign(to: &$pictureHeader)
        
        $editPressed
            .flatMap { [weak self] pressed -> AnyPublisher<String, Never> in
                if pressed == true || self!.mode == .createAccount {
                    return Just("What do you do for a living?").eraseToAnyPublisher()
                } else {
                    if self!.checkForVowel(self!.jobText){
                        return Just("I'm an").eraseToAnyPublisher()
                    } else {
                        return Just("I'm a").eraseToAnyPublisher()
                    }
                }
            }
            .assign(to: &$jobHeader)
        
        $editPressed
            .flatMap { [weak self] bool -> AnyPublisher<String, Never> in
                if bool == true || self!.mode == .createAccount {
                    return Just("Where did you go to school?").eraseToAnyPublisher()
                } else {
                    return Just("I went to").eraseToAnyPublisher()
                }
            }
            .assign(to: &$schoolHeader)
        
        doubleKnobSlider.highHandle.objectWillChange.sink { [weak self] _ in
            if self!.editPressed {
                self!.coreChanged = true
            }
        }.store(in: &cancellables)
        
        doubleKnobSlider.lowHandle!.objectWillChange.sink { [weak self] _ in
            if self!.editPressed {
                self!.coreChanged = true
            }
        }.store(in: &cancellables)
        
        singleKnobSlider.highHandle.objectWillChange.sink { [weak self] _ in
            if self!.editPressed {
                self!.coreChanged = true
            }
        }.store(in: &cancellables)
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
    
    public func editProfile() {
        if editPressed {
            //check all flags
            if coreChanged {
                handleUpdateUserCore()
                coreChanged = false
            }
            
            if aboutChanged {
                handleUpdateUserAbout()
                aboutChanged = false
            }
            
            if imgsChanged {
                handleUpdateImgs()
                imgsChanged = false
            }
            
            if profileImgChanged {
                handleUpdateProfilePic()
                profileImgChanged = false
            }
            
            editPressed = false 
        } else {
            editPressed = true
        }
    }
    
    private func handleUpdateUserCore() {
        print("CoreChanged")
        //when we update our UserCore, we need to:
        //  1. Update the UserCore
        //  2. Update the current UserCore
        //  3. Refetch stories on explore that match new userCore
        let updateUC = UserCore(
            uid: AuthService.shared.currentUser!.uid,
            name: nameText,
            age: age,
            gender: selectGenderDropDownText.rawValue,
            sexuality: selectSexualityDropDownText.rawValue,
            ageMinPref: Int(min(doubleKnobSlider.lowHandle!.currentValue, doubleKnobSlider.highHandle.currentValue)),
            ageMaxPref: Int(max(doubleKnobSlider.lowHandle!.currentValue, doubleKnobSlider.highHandle.currentValue)),
            willingToTravel: Int(singleKnobSlider.highHandle.currentValue),
            longitude: LocationService.shared.coordinates.longitude,
            latitude: LocationService.shared.coordinates.latitude
        )
        
        UserCoreService.shared.addNewUser(core: updateUC)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ProfileViewModel: Failed to update UserCore")
                    print("ProfileViewModel-err: \(e.localizedDescription)")
                case .finished:
                    print("ProfileViewModel: Finished updating UserCore")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        
        //Refetch RecentlyJoined and refetch vibe stories
    }
    
    private func handleUpdateUserAbout() {
        print("About Changed")
        //When we update our UserAbout, we need to:
        //  1. Update the UserAbout document
        
        UserAboutService.shared.setUserAbout(bio: bioText, job: jobText, school: schoolText)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ProfileViewModel: Failed to update User About")
                    print("ProfileViewModel-err: \(e.localizedDescription)")
                case .finished:
                    print("ProfileViewModel: Finished updating User About")
                }
            } receiveValue: { _ in}
            .store(in: &cancellables)
    }
    
    private func handleUpdateImgs() {
        print("Imgs Changed")
        //When we update our imgs, we need to:
        //  1. Push all images with their new indexes
        //  2. If we do not have exactly 6 imgs in array, we need to delete the higher indexes
        let maxImgCount = 6
        let currentImgCount = images.count
        
        //The indexes should already be correct
        // This is just to be sure
        for i in 0..<images.count {
            images[i].index = i + 1
        }
        
        if maxImgCount - currentImgCount == 0 {
            //Overwrite all images
            for img in images {
                ProfileImageService.shared.uploadProfileImage(img: img, name: "\(img.index)")
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileViewModel: Failed to update img w index -> \(img.index)")
                            print("ProfileViewModel-err: \(e.localizedDescription)")
                        case .finished:
                            print("ProfileViewModel: Finished updating img w index -> \(img.index)")
                        }
                    } receiveValue: { _ in }
                    .store(in: &cancellables)
            }
        } else {
            //We do not have full images
            //Overwrite the images we already have
            for img in images {
                ProfileImageService.shared.uploadProfileImage(img: img, name: "\(img.index)")
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileViewModel: Failed to update img w index -> \(img.index)")
                            print("ProfileViewModel-err: \(e.localizedDescription)")
                        case .finished:
                            print("ProfileViewModel: Finished updating img w index -> \(img.index)")
                        }
                    } receiveValue: { _ in }
                    .store(in: &cancellables)
            }
            
            //We now need to delete the remaining images
            let loopTimes = maxImgCount - currentImgCount
            
            for i in 0..<loopTimes {
                ProfileImageService.shared.deleteProfileImage(index: "\(maxImgCount - i)")
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileViewModel: Failed to delete img w index -> \(maxImgCount - i)")
                            print("ProfileViewModel-err: \(e.localizedDescription)")
                        case .finished:
                            print("ProfileViewModel: Finished delete img w index -> \(maxImgCount - i)")
                        }
                    } receiveValue: { _ in }
                    .store(in: &cancellables)
            }
        }
    }
    
    private func handleUpdateProfilePic() {
        print("Profile pic changed")
        //When we update the profile pic, we need to:
        //  1. Check to see if there is an image in profilePics
        //      a. if there is an image, we overwrite the img in place 1
        //      b. if there is not an image, we delete the current 0th place img
        if profileImage.count == 0 {
            ProfileImageService.shared.deleteProfileImage(index: "0")
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ProfilViewModel: Failed to delete profile img")
                        print("ProfileViewModel-err: \(e)")
                    case .finished:
                        print("ProfileViewModel: Finished deleting Profile pic")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        } else {
            ProfileImageService.shared.uploadProfileImage(img: profileImage[0], name: "0")
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("ProfilViewModel: Failed to update profile img")
                        print("ProfileViewModel-err: \(e)")
                    case .finished:
                        print("ProfileViewModel: Finished update Profile pic")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
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
    
    public func deleteImage(at i: Int){
        if images.count > i {
            images.remove(at: i)
            
            for i in 0..<images.count {
                images[i].index = i + 1
            }
                        
            imgsChanged = true
        }
    }
    
    public func getProfilePic() -> UIImage?{
        if profileImage.count == 1 {
            return profileImage[0].image
        } else {
            return nil
        }
    }
    
    public func deleteProfilePic() {
        if profileImage.count == 1 {
            profileImage.remove(at: 0)
            
            profileImgChanged = true
        }
    }
    
    func printImageIndexes() {
        for img in images {
            print("Image -> \(img.index)")
        }
    }
    
    func printProfileImageIndex() {
        for img in profileImage {
            print("Image -> \(img.index)")
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
            ageMinPref: Int(min(doubleKnobSlider.lowHandle!.currentValue, doubleKnobSlider.highHandle.currentValue)),
            ageMaxPref: Int(max(doubleKnobSlider.lowHandle!.currentValue, doubleKnobSlider.highHandle.currentValue)),
            willingToTravel: Int(singleKnobSlider.highHandle.currentValue),
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
                }
            } receiveValue: { [weak self] _ in
                self!.loading = false
                AppState.shared.allowAccess = true
                AppState.shared.createAccountPressed = false
                self!.submitPressed = true
            }.store(in: &cancellables)
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
            } receiveValue: { [weak self] text, mainImgs, sideImgs in
                if text == nil || mainImgs == nil || sideImgs == nil {
                    returnedNil = true
                } else {
                    //Populate UI w/ text
                    self!.nameText = text!.name
                    self!.age = text!.birthday
                    self!.ageText = self!.age.ageString()
                    
                    if let bio = text?.bio {
                        self!.bioText = bio
                    }
                    
                    if text?.gender == "male" || text?.gender == "Male" {
                        self!.selectGenderDropDownText = .male
                    } else {
                        self!.selectGenderDropDownText = .female
                    }
                    
                    if text?.sexuality == "gay" || text?.sexuality == "Gay"{
                        self!.selectSexualityDropDownText = .gay
                    } else if text?.sexuality == "Straight" || text?.sexuality == "straight" {
                        self!.selectSexualityDropDownText = .straight
                    } else {
                        self!.selectSexualityDropDownText = .bisexual
                    }
                    
                    if let job = text?.job {
                        self!.jobText = job
                    }
                    
                    if let school = text?.school {
                        self!.schoolText = school
                    }
                    
                    //Populate UI w/ mainImg
                    if let main = mainImgs {
                        self!.profileImage += main
                    }
                    
                    //Populate UI w/ sideImgs
                    if let side = sideImgs {
                        self!.images += side
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
        
        ProfileService.shared.getFullProfile(uid: uid)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    print("getting profile from firebase: ProfileViewModel")
                }
            } receiveValue: { [weak self] core, abt, imgs in

                if let core = core {
                    //Assign Core profile to UserService
                    
                    self!.age = core.age
                    self!.ageText = self!.age.ageString()
                    self!.nameText = core.name
                    self!.selectGenderDropDownText = "male" == core.gender || "Male" == core.gender ? .male : .female
                    
                    if core.sexuality == "Gay" || core.sexuality == "gay" {
                        self!.selectSexualityDropDownText = .gay
                    } else if core.sexuality == "Straight" || core.sexuality == "straight" {
                        self!.selectSexualityDropDownText = .straight
                    } else {
                        self!.selectSexualityDropDownText = .bisexual
                    }
                    
                    let ageMin = 18
                    let ageMax = 99
                    
                    let range = ageMax - ageMin
                    let ageMinPrefPercent = Double((core.ageMinPref - ageMin)) / Double(range)
                    let ageMaxPrefPercent = Double((core.ageMaxPref - ageMin)) / Double(range)
                        
                    self!.doubleKnobSlider.lowHandle!.currentPercentage = SliderValue(wrappedValue: ageMinPrefPercent)
                    self!.doubleKnobSlider.highHandle.currentPercentage = SliderValue(wrappedValue: ageMaxPrefPercent)
                                        
                    self!.doubleKnobSlider.lowHandle!.currentLocation = CGPoint(x: (CGFloat(ageMinPrefPercent)/1.0) *        self!.doubleKnobSlider.lowHandle!.sliderWidth, y: self!.doubleKnobSlider.lowHandle!.sliderHeight / 2)
                    self!.doubleKnobSlider.highHandle.currentLocation = CGPoint(x: (CGFloat(ageMaxPrefPercent)/1.0) * self!.doubleKnobSlider.highHandle.sliderWidth, y: self!.doubleKnobSlider.highHandle.sliderHeight / 2)
                }
                
                if let abt = abt {
                    self!.bioText = abt.bio ?? ""
                    self!.jobText = abt.job ?? ""
                    self!.schoolText = abt.school ?? ""
                }
                
                if let imgs = imgs {
                    self!.profileImage.append(imgs[0])
                    
                    for i in 1 ..< imgs.count {
                        self!.images.append(imgs[i])
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
