//
//  LandingView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct LandingPageView: View {
    
//MARK: - View State Variables
    
    @StateObject var viewModel = LandingPageViewModel()
    
//MARK: - Main Body
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                
                VStack{
                    Spacer()
                        .frame(height: screenHeight * 0.2)
                    
                    title
                    
                    Spacer()
                    
                    signupButton
                    
                    loginButton
                }
                .frame(width: screenWidth, height: screenHeight) //Color.red, Color.red.opacity(0.8)
                .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.pink.opacity(0.8), .black]), startPoint: .topLeading, endPoint: .bottom))
                .edgesIgnoringSafeArea(.all)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }

//MARK: - View Variables
    
    var title: some View{
        VStack {
            Text(viewModel.welcomeText)
                .foregroundColor(.white)
                .padding()
            
            Text(viewModel.toText)
                .foregroundColor(.white)
            
            Text(viewModel.galaText)
                .foregroundColor(.white)
                .padding()
        }
        .font(.system(size: 60, weight: .bold, design: .rounded))
    }
    
    var signupButton: some View {
        NavigationLink(
            destination: SigninSignupView(viewModel: SigninSignupViewModel(mode: .signUp)),
            isActive: $viewModel.signupButtonPressed
        ){
            Button(action: {
                viewModel.signupButtonPressed = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color.yellow)
                        .frame(width: screenWidth * 0.7, height: screenHeight * 0.1, alignment: .center)
                    
                    Text(viewModel.signupButtonText)
                        .foregroundColor(.black)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                }
            }
        }
    }
    
    var loginButton: some View {
        NavigationLink(
            destination: SigninSignupView(viewModel: SigninSignupViewModel(mode: .login)),
            isActive: $viewModel.loginButtonPressed
        ){
            Button(action: {
                viewModel.loginButtonPressed = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color.yellow.opacity(0.8))
                        .frame(width: screenWidth * 0.7, height: screenHeight * 0.1, alignment: .center)
                    
                    Text(viewModel.loginButtonText)
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                }
            }
            .padding()
            .padding(.bottom, 25)
        }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}

