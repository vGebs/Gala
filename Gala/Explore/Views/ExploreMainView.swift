//
//  ExploreMainView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-25.
//

import SwiftUI

struct ExploreMainView: View {
    var optionButtonLeft: String = "rectangle.stack.person.crop"
    var pageName: String = "Explore"
    var optionButtonRight: String = "line.horizontal.3"
    var baseColor: Color = .blue
    
    @ObservedObject var viewModel: ExploreViewModel
    @ObservedObject var profile: ProfileViewModel
    
    @State var showProfile = false
    
    @Binding var showVibe: Bool
    @Binding var selectedVibe: ColorStruct
    @Binding var offset: CGSize
    @Binding var scale: CGFloat
    
    var animation: Namespace.ID
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        VStack {
            ZStack{
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
                        ExploreView(viewModel: viewModel, selectedVibe: $selectedVibe, animation: animation, showVibe: $showVibe, offset: $offset, scale: $scale) //, showVibe: $showVibe
                    }
                    .frame(width: screenWidth, height: screenHeight * 0.81)
                    .cornerRadius(20)
                }
                
                VStack {
                    HStack {
                        Button(action: { self.showProfile = true }) {
                            Image(systemName: optionButtonLeft)
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text(pageName)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.pink)

                        Spacer()
                        
                        Button(action: { }) {
                            Image(systemName: optionButtonRight)
                                .font(.system(size: 22, weight: .regular, design: .rounded))
                                .foregroundColor(.blue)
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
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: profile, showProfile: $showProfile)
        })
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

