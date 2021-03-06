//
//  AppState.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-06-02.
//

import SwiftUI
import Combine
import FirebaseAuth
import Firebase
import FirebaseFirestore

class AppState: ObservableObject {
    
    @AppStorage("isDarkMode") var isDarkMode = true
    
    static let shared = AppState()
    
    @Published var location = LocationService.shared
    
    //ViewState variables
    @Published var allowAccess: Bool = false
    @Published var onLandingPage: Bool = true
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
    @Published var loginVM: SigninSignupViewModel? //DONE
    @Published var signUpVM: SigninSignupViewModel? //DONE
    @Published var createProfileVM: ProfileViewModel? //DONE
    
    //Main ViewModels
    @Published var profileVM: ProfileViewModel? //DONE
    @Published var chatsVM: ChatsViewModel? //DONE
    @Published var cameraVM: CameraViewModel? //DONE //deinit when camera.tearDownCamera() is called (see logout() func)
    @Published var exploreVM: ExploreViewModel? //DONE
    
    private var subs: [AnyCancellable] = []
    
    @Published var currentUser = AuthService.shared.currentUser
    
    private var db = Firestore.firestore()
    
    private func userCoreIsEmpty(_ uc: UserCore) -> Bool {
        if uc.userBasic.gender == "" {
            return true
        } else {
            return false
        }
    }
    
    private init() {
        
        $currentUser
            .flatMap { UserCoreService.shared.getUserCore(uid: $0?.uid) }
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("AppState: CurrentUser is empty")
                    print("AppState-err: \(e)")
                case .finished:
                    print("AppState: Finished fetching usercore")
                }
            } receiveValue: { [weak self] uc in
                if let uc = uc {
                    // We need to make sure that the LocationService class is initialized so we can fetch the stories with our current location. We need this b/c it is a singleton
                    let _ = LocationService.shared.city
                    
                    if self!.userCoreIsEmpty(uc) {
                        
                        self?.profileInfo.name = uc.userBasic.name
                        self?.profileInfo.age = uc.userBasic.birthdate
                        
                        withAnimation {
                            self?.signUpPageActive = false
                            self?.loginPageActive = false
                            self?.createAccountPressed = true
                        }
                    } else {
                        NotificationService.shared.observeNotifications()
                        self?.allowAccess = true
                    }
                }
            }
            .store(in: &subs)
        
        $loginPageActive
            .flatMap{ [weak self] on -> AnyPublisher<SigninSignupViewModel?, Never> in
                if on {
                    self?.onLandingPage = false
                    return Just(SigninSignupViewModel(mode: .login)).eraseToAnyPublisher()
                } else {
                    print("AppState: Setting Login VM to nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$loginVM)
        
        $signUpPageActive
            .flatMap { [weak self] on -> AnyPublisher<SigninSignupViewModel?, Never> in
                if on {
                    self?.onLandingPage = false
                    return Just(SigninSignupViewModel(mode: .signUp)).eraseToAnyPublisher()
                } else {
                    print("AppState: Setting Signup VM to nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$signUpVM)
        
        $createAccountPressed
            .flatMap{ [weak self] on -> AnyPublisher<ProfileViewModel?, Never> in
                if on {
                    return Just(ProfileViewModel(name: self!.profileInfo.name, age: self!.profileInfo.age, email: self!.profileInfo.email, mode: .createAccount, uid: nil)).eraseToAnyPublisher()
                } else {
                    print("AppState: Setting Create profile VM to nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$createProfileVM)
        
        $allowAccess
            .flatMap{ allow -> AnyPublisher<ProfileViewModel?, Never> in
                if allow {
                    return Just(ProfileViewModel(mode: .profileStandard, uid: AuthService.shared.currentUser!.uid)).eraseToAnyPublisher()
                } else {
                    print("AppState: Setting Profile Standard to nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$profileVM)

        $allowAccess
            .flatMap { allow -> AnyPublisher<CameraViewModel?, Never> in
                if allow {
                    return Just(CameraViewModel()).eraseToAnyPublisher()
                } else {
                    print("AppState: Setting CameraVM to nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .assign(to: &$cameraVM)
        
        $allowAccess
            .flatMap { allow ->  AnyPublisher<ExploreViewModel?, Never> in
                if allow {
                    return Just(ExploreViewModel()).eraseToAnyPublisher()
                } else {
                    print("AppState: Setting ExploreViewModel to nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }.assign(to: &$exploreVM)
        
        $allowAccess
            .flatMap { allow ->  AnyPublisher<ChatsViewModel?, Never> in
                if allow {
                    return Just(ChatsViewModel()).eraseToAnyPublisher()
                } else {
                    print("AppState: Setting ChatsViewModel to nil")
                    return Just(nil).eraseToAnyPublisher()
                }
            }.assign(to: &$chatsVM)
    }

    public func logout() {
        
        db.collection("FCM Tokens").document(AuthService.shared.currentUser!.uid).updateData([
            "loggedIn": 0
        ]) { err in
            if let err = err {
                print("AppState: Failed to update loggedIn Status")
                print("AppState-err: \(err)")
            } else {
                print("AppState: Finished setting loggedIn status to false")
            }
        }
        
        DataStore.shared.clear()
        cameraVM?.tearDownCamera()
        AppState.shared.allowAccess = false
        AppState.shared.onLandingPage = true
        
        UserCoreService.shared.currentUserCore = nil
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            AuthService.shared.logout()
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("AppState: Failed to logout")
                        print("AppState-err: \(e)")
                    case .finished:
                        print("AppState: Finished logging out")
                    }
                } receiveValue: { _ in }
                .store(in: &self!.subs)
        }
    }
    
    public func toggleDarkMode() {
        isDarkMode.toggle()
    }
}
