//
//  AppState.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-06-02.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    
    //Shared Instance (Singleton)
    static let shared = AppState()
    
    //ViewState variables
    @Published var allowAccess: Bool = UserService.shared.currentUser == nil ? false : true
    @Published var onLandingPage: Bool = UserService.shared.currentUser == nil ? true : false
    @Published var loginPressed = false
    @Published var signUpPressed = false
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
    //@Published var exploreVM:
    //@Published var showcaseVM:
    
    private init() {
        
        $onLandingPage
            .flatMap{ on -> AnyPublisher<LandingPageViewModel?, Never> in
                if on {
                    return Just(LandingPageViewModel()).eraseToAnyPublisher()
                } else {
                    print("Landing form set nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }.assign(to: &$landingVM)
        
        $loginPressed
            .flatMap{ on -> AnyPublisher<SigninSignupViewModel?, Never> in
                if on {
                    return Just(SigninSignupViewModel(mode: .login)).eraseToAnyPublisher()
                } else {
                    print("Login form set nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$loginVM)
        
        $signUpPressed
            .flatMap { on -> AnyPublisher<SigninSignupViewModel?, Never> in
                if on {
                    return Just(SigninSignupViewModel(mode: .signUp)).eraseToAnyPublisher()
                } else {
                    print("Signup form set nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$signUpVM)
        
        $createAccountPressed
            .flatMap{ on -> AnyPublisher<ProfileViewModel?, Never> in
                if on {
                    return Just(ProfileViewModel(name: self.profileInfo.name, age: self.profileInfo.age, email: self.profileInfo.email, mode: .createAccount)).eraseToAnyPublisher()
                } else {
                    print("Create profile form set nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$createProfileVM)
        
        $allowAccess
            .flatMap{ allow -> AnyPublisher<ProfileViewModel?, Never> in
                if allow {
                    return Just(ProfileViewModel(mode: .profileStandard)).eraseToAnyPublisher()
                } else {
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$profileVM)
        
        $allowAccess
            .flatMap { allow -> AnyPublisher<CameraViewModel?, Never> in
                if allow {
                    return Just(CameraViewModel(volumeCameraButton: false)).eraseToAnyPublisher()
                } else {
                    print("camera = nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$cameraVM)
    }
}
