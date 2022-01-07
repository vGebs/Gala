//
//  ChatsView2.swift
//  Gala
//
//  Created by Vaughn on 2021-08-31.
//

import SwiftUI
import Combine

struct ChatsView: View {
    var optionButtonLeft: String = "rectangle.stack.person.crop"
    var pageName: String = "Chats"
    var optionButtonRight: String = "square.and.pencil"
    
    //@ObservedObject var viewModel: ProfileViewModel

    private var cancellables: [AnyCancellable] = []
    
    @StateObject var viewModel = ChatsViewModel()
    @ObservedObject var profile: ProfileViewModel
    
    @State var showProfile = false
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    init(profile: ProfileViewModel){
        self.profile = profile
    }
    
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
                        
                    }
                    .frame(width: screenWidth, height: screenHeight * 0.81)
                    .cornerRadius(20)
                }
                
                VStack {
                    HStack {
                        Button(action: { self.showProfile = true }) {
                            Image(systemName: optionButtonLeft)
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                        
                        Spacer()
                        
                        Text(pageName)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        Spacer()
                        
                        Button(action: { }) {
                            Image(systemName: optionButtonRight)
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.buttonPrimary)
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

//struct ChatsView2_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatsView()
//    }
//}
