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
    
    @StateObject var state = AppState.shared

    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if state.allowAccess {
                ContentView(chat: state.chatsVM!, camera: state.cameraVM!, profile: state.profileVM!, explore: state.exploreVM!)
                
            } else if state.createAccountPressed {
                ProfileView(viewModel: state.createProfileVM!)
                    .transition(.move(edge: .leading))

            } else if state.loginPageActive{
                SigninSignupView(viewModel: state.loginVM!)

            } else if state.signUpPageActive {
                SigninSignupView(viewModel: state.signUpVM!)
                
            } else {
                LandingView()
                    .transition(.move(edge: .leading))
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
