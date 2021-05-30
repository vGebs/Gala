//
//  LandingPageViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Combine

final class LandingPageViewModel: ObservableObject{
    
    @Published var signupButtonPressed = false
    @Published var loginButtonPressed = false
    
    private(set) var welcomeText: String = "Welcome"
    private(set) var toText: String = " to "
    private(set) var galaText: String = "Gala"
    private(set) var signupButtonText: String = "Sign up"
    private(set) var loginButtonText: String = "Log in"
}
