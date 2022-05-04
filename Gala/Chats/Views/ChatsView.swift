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
    
    private var cancellables: [AnyCancellable] = []
    
    @ObservedObject var viewModel: ChatsViewModel
    @ObservedObject var profile: ProfileViewModel
    
    @State var showProfile = false
    
    @State var draggedOffset: CGFloat = -screenWidth * 2

    @AppStorage("isDarkMode") private var isDarkMode = true
    
    init(viewModel: ChatsViewModel, profile: ProfileViewModel){
        //self._selectedChat = selectedChat
        self.profile = profile
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
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
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundColor(.black)
                                .frame(height: screenHeight * 0.015)
                            
                            ForEach(viewModel.matches){ match in
                                ConvoPreview(ucMatch: match, showChat: $viewModel.showChat, user: $viewModel.userChat, messages: $viewModel.matchMessages, timeMatchedBinding: $viewModel.timeMatched, chatsViewModel: viewModel)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(width: screenWidth, height: screenHeight * 0.9)
                        .cornerRadius(20)
                    }
                    
                    VStack {
                        HStack {
                            Button(action: {
                                self.showProfile = true
                            }) {
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
                .frame(width: screenWidth, height: screenHeight) //* 0.91
                .edgesIgnoringSafeArea(.all)
                Spacer()
            }
            .sheet(isPresented: $showProfile, content: {
                ProfileMainView(viewModel: profile, showProfile: $showProfile)
            })
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
