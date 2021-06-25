//
//  LaunchView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-30.
//

import Foundation
import SwiftUI
import Combine

struct LaunchView: View {
    
    @StateObject var viewModel = AppState.shared

    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        ZStack {
            if viewModel.allowAccess {
                ContentView(camera: viewModel.cameraVM!, profile: viewModel.profileVM!, explore: viewModel.exploreVM!)

            } else if viewModel.createAccountPressed {
                ProfileView(viewModel: viewModel.createProfileVM!)
                    .transition(.move(edge: .leading))

            } else if viewModel.loginPageActive{
                SigninSignupView(viewModel: viewModel.loginVM!)

            } else if viewModel.signUpPageActive {
                SigninSignupView(viewModel: viewModel.signUpVM!)
                
            } else {
                LandingPageView(viewModel: viewModel.landingVM!)
                    .transition(.move(edge: .leading))
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
