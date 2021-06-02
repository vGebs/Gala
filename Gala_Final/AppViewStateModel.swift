//
//  AppViewStateModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-31.
//

import Foundation
import Combine
import SwiftUI

class AppViewStateModel: ObservableObject {
    static let shared = AppViewStateModel()
    
    //Used to determine whether or not we will skip authentication
    @Published var userLoggedIn = UserService.shared.currentUser != nil
    
    @Published var signUpViewActivated = false
    @Published var createAccountPressed = false
    @Published var submitProfilePressed = false
    
    @Published var loginViewActivated = false
    @Published var loginPressed = false
    
    
    private init () {  }
}

enum SignUpOrLogin {
    case signUp
    case login
    case none
}
