//
//  ProfileMainView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ProfileMainView: View {
    var optionButtonLeft: String = "highlighter"
    var pageName: String = "Profile"
    var optionButtonRight: String = "gearshape"
    
    @ObservedObject var viewModel: ProfileViewModel

    @AppStorage("isDarkMode") private var isDarkMode = true
    
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
                        Button(action: { }) {
                            Image(systemName: optionButtonLeft)
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                        
                        Spacer()
                        
                        Text(pageName)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        Spacer()
                        
                        Menu {
                            Button(action: { AppState.shared.toggleDarkMode() }){
                                HStack{
                                    Image(systemName: "person.fill.xmark")
                                    Text(AppState.shared.isDarkMode ? "Toggle light mode" : "Toggle dark mode")
                                }
                            }
                            
                            Button(action: { self.viewModel.logout() }){
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
