//
//  LaunchView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-30.
//

import Foundation
import SwiftUI
import Combine
import SwiftUICam

struct LaunchView: View {
    
    @ObservedObject var viewModel = LaunchViewModel.shared
    
    var body: some View {
        ZStack {
            if viewModel.allowAccess {
                ContentView()
                    .environmentObject(SwiftUICamModel(volumeCameraButton: false))
            } else if viewModel.loginPressed{
                SigninSignupView(viewModel: SigninSignupViewModel(mode: .login))
                
            } else if viewModel.signUpPressed {
                SigninSignupView(viewModel: SigninSignupViewModel(mode: .signUp))
                
            } else if viewModel.createAccountPressed {
                ProfileView(viewModel: ProfileViewModel(name: viewModel.profile.name, age: viewModel.profile.age, email: viewModel.profile.email, mode: .createAccount))
                
            } else {
                LandingPageView()
            }
        }
    }
}
