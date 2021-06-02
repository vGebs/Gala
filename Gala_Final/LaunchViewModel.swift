//
//  LaunchViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-06-01.
//

import SwiftUI
import Combine

class LaunchViewModel: ObservableObject{
    
    static let shared = LaunchViewModel()
    
    @Published var allowAccess: Bool = UserService.shared.currentUser == nil ? false : true
    @Published var onLandingPage: Bool = UserService.shared.currentUser == nil ? true : false
    @Published var loginPressed = false
    @Published var signUpPressed = false
    @Published var createAccountPressed = false
    
    @Published var profile: ProfileViewInfo = ProfileViewInfo(name: "", age: Date(), email: "")
    
    struct ProfileViewInfo {
        var name: String
        var age: Date
        var email: String
    }
    
    private init() {  }
}
