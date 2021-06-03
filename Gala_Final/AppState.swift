//
//  AppState.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-06-02.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    
    @AppStorage("isDarkMode") var isDarkMode = true
    
    //Shared Instance (Singleton)
    static let shared = AppState()
    
    //ViewState variables
    @Published var allowAccess: Bool = UserService.shared.currentUser == nil ? false : true
    @Published var onLandingPage: Bool = UserService.shared.currentUser == nil ? true : false
    @Published var loginPageActive = false
    @Published var signUpPageActive = false
    @Published var createAccountPressed = false
    
    //ProfileInfo for passing of data
    @Published var profileInfo: ProfileViewInfo = ProfileViewInfo(name: "", age: Date(), email: "")
    
    struct ProfileViewInfo {
        var name: String
        var age: Date
        var email: String
    }
    
    //Auth ViewModels
    @Published var landingVM: LandingPageViewModel?
    @Published var loginVM: SigninSignupViewModel?
    @Published var signUpVM: SigninSignupViewModel?
    @Published var createProfileVM: ProfileViewModel?
    
    //Main ViewModels
    @Published var profileVM: ProfileViewModel?
    //@Published var chats: ChatsViewModel?
    @Published var cameraVM: CameraViewModel?
    //@Published var exploreVM: ExploreViewModel?
    //@Published var showcaseVM: ShowCaseViewModel?
    
    //Side ViewModels
    //@Published var settingVM: SettingsViewModel?
    //...
    
    private init() {
        
//        UserService.shared
//            .observeAuthChanges()
//            .map { $0 != nil }
//            .assign(to: &$allowAccess)
//
//        UserService.shared
//            .observeAuthChanges()
//            .map { $0 == nil }
//            .assign(to: &$onLandingPage)
        
        $onLandingPage
            .flatMap{ on -> AnyPublisher<LandingPageViewModel?, Never> in
                if on {
                    return Just(LandingPageViewModel()).eraseToAnyPublisher()
                } else {
                    print("Setting Landing VM to nil: AppState.swift")
                    return Just(nil).eraseToAnyPublisher()
                }
            }.assign(to: &$landingVM)
        
        $loginPageActive
            .flatMap{ on -> AnyPublisher<SigninSignupViewModel?, Never> in
                if on {
                    return Just(SigninSignupViewModel(mode: .login)).eraseToAnyPublisher()
                } else {
                    print("Setting Login VM to nil: AppState.swift")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$loginVM)
        
        $signUpPageActive
            .flatMap { on -> AnyPublisher<SigninSignupViewModel?, Never> in
                if on {
                    return Just(SigninSignupViewModel(mode: .signUp)).eraseToAnyPublisher()
                } else {
                    print("Setting Signup VM to nil: AppState.swift")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$signUpVM)
        
        $createAccountPressed
            .flatMap{ on -> AnyPublisher<ProfileViewModel?, Never> in
                if on {
                    return Just(ProfileViewModel(name: self.profileInfo.name, age: self.profileInfo.age, email: self.profileInfo.email, mode: .createAccount)).eraseToAnyPublisher()
                } else {
                    print("Setting Create profile VM to nil: AppState.swift")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$createProfileVM)
        
        $allowAccess
            .flatMap{ allow -> AnyPublisher<ProfileViewModel?, Never> in
                if allow {
                    return Just(ProfileViewModel(mode: .profileStandard)).eraseToAnyPublisher()
                } else {
                    print("Setting all ContentViews = nil: AppState.swift")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$profileVM)

        $allowAccess
            .flatMap { allow -> AnyPublisher<CameraViewModel?, Never> in
                if allow {
                    return Just(CameraViewModel(volumeCameraButton: false)).eraseToAnyPublisher()
                } else {
                    print("Setting Camera VM to nil: AppState.swift")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$cameraVM)
    }
    
    public func toggleDarkMode() {
        isDarkMode.toggle()
    }
}
