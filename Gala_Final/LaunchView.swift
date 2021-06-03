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
    
    @ObservedObject var viewModel = AppState.shared
    
    var body: some View {
        ZStack {
            if viewModel.allowAccess {
                ContentView(camera: viewModel.cameraVM!, profile: viewModel.profileVM!)

            }  else if viewModel.createAccountPressed {
                ProfileView(viewModel: viewModel.createProfileVM!)
                    .transition(.move(edge: .leading))

            } else if viewModel.loginPressed{
                SigninSignupView(viewModel: viewModel.loginVM!)

            } else if viewModel.signUpPressed {
                SigninSignupView(viewModel: viewModel.signUpVM!)
                
            } else {
                LandingPageView(viewModel: viewModel.landingVM!)
                    .transition(.move(edge: .leading))
            }
        }
    }
}
