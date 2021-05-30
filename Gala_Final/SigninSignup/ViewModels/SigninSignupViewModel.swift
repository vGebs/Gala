//
//  SigninSignupViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine
import Foundation

final class SigninSignupViewModel: ObservableObject{

//MARK: - General Purpose Variables
    
    private let userService = UserService.shared
    private var cancellables: [AnyCancellable] = []

    private(set) var agePlaceholderText = "Birthday"
    private(set) var namePlaceholderText = "First name"
    private(set) var emailPlaceholderText = "Email"
    private(set) var cellNumberPlaceholder = "Cell phone number"
    private(set) var passwordPlaceholderText = "Password"
    private(set) var reEnterPasswordPlaceholderText = "Re-enter password"
    
    private(set) var ageWarning = "Must be 18 years of age"
    private(set) var nameWarning = "Name must have at least 2 characters"
    private(set) var emailWarning = "Please enter your email"
    private(set) var cellNumWarning = "Please enter your cell number with your area code"
    private(set) var passwordWarning = "Password must be at least 6 characters"
    private(set) var rePasswordWarning = "Match your password"
    
    @Published var enterProfileTapped = false
    @Published var enterMainScreenTapped = false
    
    @Published var age = Date()
    @Published var nameText = ""
    @Published var emailText = ""
    @Published var cellNumberText = ""
    @Published var passwordText = ""
    @Published var reEnterPasswordText = ""
        
    @Published var ageIsValid = false
    @Published var nameIsValid = false
    @Published var emailIsValid = false
    @Published var passwordIsValid = false
    @Published var rePasswordIsValid = false
    @Published var cellNumIsValid = false
            
    private var loginReady: Bool {
         (emailIsValid || cellNumIsValid) && passwordIsValid
    }
    
    private var signupReady: Bool {
        ageIsValid &&
            nameIsValid &&
            emailIsValid &&
            passwordIsValid &&
            rePasswordIsValid
            //cellNumIsValid
    }
    
    var isValid: Bool {
        switch mode{
        case .signUp:
            return signupReady
        case .login:
            return loginReady
        }
    }
    
    @Published var loginError = true
    let loginErrorMessage = "Username or password incorrect"
    
    @Published var signUpError = false
    let signUpErrorMessage = "This email address is already in use"
    
    @Published var loading = false
    
    let mode: Mode
    
//MARK: - Enums
    
    enum Mode {
        case login
        case signUp
    }
    
//MARK: - Initializer
    
    init(mode: Mode){
        self.mode = mode
        
        switch mode{
        case .signUp:
            
            $age
                .flatMap{ age -> AnyPublisher<Bool, Never> in
                    age.isAgeValid()
                }
                .assign(to: &$ageIsValid)
            
            $nameText
                .flatMap{ name -> AnyPublisher<Bool, Never> in
                    name.isNameStringValid()
                }
                .assign(to: &$nameIsValid)
            
            $emailText
                .flatMap{ email -> AnyPublisher<Bool, Never> in
                    email.isEmailStringValid()
                }
                .assign(to: &$emailIsValid)
            
            $passwordText
                .flatMap{ pword -> AnyPublisher<Bool, Never> in
                    pword.isPasswordStringValid()
                }
                .assign(to: &$passwordIsValid)
            
            Publishers.CombineLatest($passwordText, $reEnterPasswordText)
                .flatMap{ (pword, rPword) -> AnyPublisher<Bool, Never> in
                    pword.isReEnterPasswordStringValid(rPword)
                }
                .assign(to: &$rePasswordIsValid)
            
            $cellNumberText
                .flatMap{ cellNum -> AnyPublisher<Bool, Never> in
                    cellNum.isCellNumberStringValid()
                }
                .assign(to: &$cellNumIsValid)
            
        case .login:
            
            $emailText
                .flatMap{ email -> AnyPublisher<Bool, Never> in
                    email.isEmailStringValid()
                }
                .assign(to: &$emailIsValid)
            
//            $cellNumberText
//                .flatMap{ cellNum -> AnyPublisher<Bool, Never> in
//                    cellNum.isCellNumberStringValid()
//                }
//                .assign(to: &$cellNumIsValid)
            
            $passwordText
                .flatMap { pword -> AnyPublisher<Bool, Never> in
                    pword.isPasswordStringValid()
                }
                .assign(to: &$passwordIsValid)
        }
    }
    
//MARK: - Mode Specific View Variables
    
    var title: String {
        switch mode {
        case .signUp:
            return "Create an Account"
        case .login:
            return "Welcome Back"
        }
    }
    
    var subtitle: String{
        switch mode {
        case .signUp:
            return "Sign up with your email & cell phone number"
        case .login:
            return "Sign in with your email or cell phone number"
        }
    }
    
    var buttonText: String {
        switch mode {
        case .signUp:
            return "Sign up!"
        case .login:
            return "Log in!"
        }
    }

//MARK: - Public Methods
    
    func tappedActionButton(){
        switch mode{
        case .signUp:
            createAccount()
        
        case .login:
            login(mode)
        }
    }
    
//MARK: - Private functions
        
    private func createAccount(){
        print("signup")
        self.loading = true
        userService.createAcoountWithEmail(email: self.emailText, password: self.passwordText)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                    self.signUpError = true
                case .finished:
                    print("Succesfully Signed up")
                    self.login(self.mode)
                    self.loading = false
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func login(_ mode: Mode){
        print("login")
        self.loading = true
        userService.signInWithEmail(email: self.emailText, password: self.passwordText)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                    self.loginError = false
                case .finished:
                    print("Succesfully Signed in")
                    UserDefaults.standard.set(true, forKey: "loggedIn")
                    UserDefaults.standard.set(self.emailText, forKey: "email")
                    UserDefaults.standard.set(self.passwordText, forKey: "password")
                    //self.loading = false
                }
            } receiveValue: { _ in
                switch mode{
                case .login:
                    self.enterMainScreenTapped = true
                    self.loading = false
                case .signUp:
                    self.enterProfileTapped = true
                    self.loading = false
                }
            }
            .store(in: &cancellables)
    }
}
