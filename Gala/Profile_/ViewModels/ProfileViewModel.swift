//
//  ProfileViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import SwiftUI

final class ProfileViewModel: ObservableObject {
    
//MARK: - General Purpose Variables
        
    private var cancellables: [AnyCancellable] = []
    
    private(set) var nameText: String
    
    @Published private(set) var cityText: String = ""
    
    @Published private(set) var countryText: String = ""
    
    private(set) var uid: String?
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
            
            if let uid = uid {
                self.uid = uid
                self.readProfile(uid: uid)
            }
        case .otherAccount:
            self.nameText = name
            self.age = age
            self.ageText = age.ageString()
            self.email = email
            
            if let uid = uid {
                self.uid = uid
                self.readProfile(uid: uid)
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
    
    public func createProfile() {
        self.loading = true
        pushProfile()
    }
    
    public func editProfile() {
        if editPressed {
            //check all flags
            var uc: UserCore?
            var abt: UserAbout?
            var profImage: [ImageModel]?
            var imgs: [ImageModel]?
            
            if coreChanged {
                uc = bundleUserCore()
                coreChanged = false
            }
            
            if aboutChanged {
                abt = UserAbout(bio: bioText, job: jobText, school: schoolText)
                aboutChanged = false
            }
            
            if profileImgChanged {
                profImage = profileImage
                profileImgChanged = false
            }
            
            if imgsChanged {
                imgs = images
                imgsChanged = false
            }
            
            if uc != nil || abt != nil || profImage != nil || imgs != nil {
                ProfileService.shared.updateCurrentUserProfile(uc: uc, abt: abt, profImage: profImage, imgs: imgs, uid: AuthService.shared.currentUser!.uid)
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let e):
                            print("ProfileViewModel: Failed to update profile")
                            print("ProfileViewModel-err: \(e)")
                        case .finished:
                            print("ProfileViewModel: Finished updating profile")
                        }
                    } receiveValue: { _ in }
                    .store(in: &cancellables)
            } else {
                print("ProfileViewModel: Nothing to update")
            }
            
            editPressed = false 
        } else {
            editPressed = true
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
}

//MARK: - Data Push & Pull ------------------------------------------------------------------------------------->
extension ProfileViewModel {
    
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
                
        let userAbout = UserAbout(
            bio: bio,
            job: job,
            school: school
        )
        
        let uc = bundleUserCore()
        
        let allImgs = profileImage + images
        
        let profile = ProfileModel(userAbout: userAbout, userCore: uc, images: allImgs)
        
        //Create Firebase Profile
        pushProfile(profile)
    }
    
    private func pushProfile(_ profile: ProfileModel) {
        if mode == .createAccount {
            ProfileService.shared.updateCurrentUserProfile(uc: profile.userCore, abt: profile.userAbout, profImage: profileImage, imgs: images, uid: AuthService.shared.currentUser!.uid)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
                .sink{ completion in
                    switch completion{
                    case let .failure(error):
                        print("ProfileViewModel: Failed to create profile")
                        print(error.localizedDescription)
                    case .finished:
                        print("Profile Successfully added to firebase: ProfileViewModel")
                    }
                } receiveValue: { [weak self] _ in
                    DataStore.shared.initialize()
                    self!.loading = false
                    AppState.shared.allowAccess = true
                    AppState.shared.createAccountPressed = false
                    self!.submitPressed = true
                }.store(in: &cancellables)
        }
    }
    
    private func readProfile(uid: String) {
        
        ProfileService.shared.getFullProfile(uid: uid)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    print("ProfileViewModel: Getting profile from firebase")
                }
            } receiveValue: { [weak self] core, abt, imgs in

                if let core = core {
                    //Assign Core profile to UserService
                    
                    self?.getCityAndCountry(
                        lat: core.searchRadiusComponents.coordinate.lat,
                        lng: core.searchRadiusComponents.coordinate.lng
                    )
                    
                    self!.age = core.userBasic.birthdate
                    self!.ageText = self!.age.ageString()
                    self!.nameText = core.userBasic.name
                    self!.selectGenderDropDownText = "male" == core.userBasic.gender || "Male" == core.userBasic.gender ? .male : .female
                    
                    if core.userBasic.sexuality == "Gay" || core.userBasic.sexuality == "gay" {
                        self!.selectSexualityDropDownText = .gay
                    } else if core.userBasic.sexuality == "Straight" || core.userBasic.sexuality == "straight" {
                        self!.selectSexualityDropDownText = .straight
                    } else {
                        self!.selectSexualityDropDownText = .bisexual
                    }
                    
                    let ageMin = 18
                    let ageMax = 99
                    
                    let range = ageMax - ageMin
                    let ageMinPrefPercent = Double((core.ageRangePreference.minAge - ageMin)) / Double(range)
                    let ageMaxPrefPercent = Double((core.ageRangePreference.maxAge - ageMin)) / Double(range)
                        
                    self!.doubleKnobSlider.lowHandle!.currentPercentage = SliderValue(wrappedValue: ageMinPrefPercent)
                    self!.doubleKnobSlider.highHandle.currentPercentage = SliderValue(wrappedValue: ageMaxPrefPercent)
                                        
                    self!.doubleKnobSlider.lowHandle!.currentLocation = CGPoint(
                        x: (CGFloat(ageMinPrefPercent)/1.0) * self!.doubleKnobSlider.lowHandle!.sliderWidth,
                        y: self!.doubleKnobSlider.lowHandle!.sliderHeight / 2
                    )
                    
                    self!.doubleKnobSlider.highHandle.currentLocation = CGPoint(
                        x: (CGFloat(ageMaxPrefPercent)/1.0) * self!.doubleKnobSlider.highHandle.sliderWidth,
                        y: self!.doubleKnobSlider.highHandle.sliderHeight / 2
                    )
                    
                    let start = 1
                    let end = 250
                    
                    let range2 = end - start
                    let percent = Double((core.searchRadiusComponents.willingToTravel - start)) / Double(range2)
                    
                    self!.singleKnobSlider.highHandle.currentPercentage = SliderValue(wrappedValue: percent)
                    self!.singleKnobSlider.highHandle.currentLocation = CGPoint(
                        x: (CGFloat(percent)/1.0) * self!.singleKnobSlider.highHandle.sliderWidth,
                        y: self!.singleKnobSlider.highHandle.sliderHeight / 2
                    )
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
    
    func getCityAndCountry(lat: Double, lng: Double) {
        LocationService.shared.getCityAndCountry(lat: lat, long: lng)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("ProfileViewModel: Failed to get city and country")
                    print("ProfileViewModel-err: \(e)")
                case .finished:
                    print("ProfileViewModel: Finished getting city and country")
                }
            } receiveValue: { [weak self] tuple in
                if let city = tuple?.0{
                    self?.cityText = city
                }
                
                if let country = tuple?.1 {
                    self?.countryText = country
                }
            }
            .store(in: &cancellables)
    }
}

//MARK: - Validation ------------------------------------------------------------------------------------->
extension ProfileViewModel {
    private func checkForVowel(_ text: String) -> Bool {
        
        if let first = text.first {
            if first == "a" || first == "e" || first == "i" || first == "o" || first == "u" {
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

//MARK: - Helpers
extension ProfileViewModel {
    private func bundleUserCore() -> UserCore {
        let basic = UserBasic(
            uid: AuthService.shared.currentUser!.uid,
            name: nameText,
            birthdate: age,
            gender: selectGenderDropDownText.rawValue,
            sexuality: selectSexualityDropDownText.rawValue
        )
        
        let agePref = AgeRangePreference(
            minAge: Int(min(doubleKnobSlider.lowHandle!.currentValue, doubleKnobSlider.highHandle.currentValue)),
            maxAge: Int(max(doubleKnobSlider.lowHandle!.currentValue, doubleKnobSlider.highHandle.currentValue))
        )
        
        let search = SearchRadiusComponents(
            coordinate: Coordinate(
                lat: LocationService.shared.coordinates.latitude,
                lng: LocationService.shared.coordinates.longitude
            ),
            willingToTravel: Int(singleKnobSlider.highHandle.currentValue)
        )
        
        let uc = UserCore(
            userBasic: basic,
            ageRangePreference: agePref,
            searchRadiusComponents: search
        )
        
        return uc
    }
}
