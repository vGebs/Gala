//
//  ProfileMainView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ProfileMainView: View {
    var optionButtonLeft: String = "rectangle.stack.person.crop"
    var pageName: String = "Profile"
    var optionButtonRight: String = "gearshape"
    
    @ObservedObject var viewModel: ProfileViewModel

    @AppStorage("isDarkMode") private var isDarkMode = true
    
    @Binding var showProfile: Bool
    
    var body: some View {
        VStack {
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(isDarkMode ? .black : .white)
                        .frame(width: screenWidth, height: screenHeight * 0.81)
                        .shadow(radius: 10)
                }
                
                VStack {
                    Spacer()
                    ScrollView(showsIndicators: false) {
                        ProfileView(viewModel: viewModel)
                    }
                    .frame(width: screenWidth, height: screenHeight * 0.81)
                    .cornerRadius(20)
                }
                
                VStack {
                    HStack {
                        Button(action: { self.showProfile = false }) {
                            Image(systemName: optionButtonLeft)
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                        
                        Spacer()
                        
                        Text(pageName)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        Spacer()
                        if viewModel.mode == .profileStandard {
                            Menu {
                                Button(action: { DataStore.shared.clearCache() }){
                                    HStack{
                                        Image(systemName: "xmark.bin")
                                        Text("Clear cache")
                                    }
                                }
                                
                                Button(action: {
                                    self.showProfile = false
                                    
                                    let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                                        AppState.shared.logout()
                                    }
                                }){
                                    HStack{
                                        Image(systemName: "person.fill.xmark")
                                        Text("Log out")
                                    }
                                }
                            } label: {
                                Label("", systemImage: optionButtonRight)
                                    .foregroundColor(.buttonPrimary)
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        } else if DataStore.shared.chats.isMatch(uid: viewModel.uid) {
                            Menu {
                                Button(action: {
                                    //unMatchUser
                                    viewModel.unMatchUser()
                                }){
                                    HStack{
                                        Image(systemName: "figure.wave")
                                        Text("Unmatch user")
                                    }
                                }
                                
                                Button(action: {
                                    //report User
                                }){
                                    HStack{
                                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                                        Text("Report user")
                                    }
                                }
                            } label: {
                                Label("", systemImage: optionButtonRight)
                                    .foregroundColor(.buttonPrimary)
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        } else {
                            Menu {
                                Button(action: {
                                    //report user
                                }){
                                    HStack{
                                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                                        Text("Report user")
                                    }
                                }
                            } label: {
                                Label("", systemImage: optionButtonRight)
                                    .foregroundColor(.buttonPrimary)
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                       
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding(.top, screenHeight * 0.0385)
            }
            .frame(width: screenWidth, height: screenHeight * 0.91)
            .edgesIgnoringSafeArea(.all)
            Spacer()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
