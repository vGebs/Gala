//
//  ContentView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ContentView: View {
    //@ObservedObject var chat: ChatsViewModel
    @ObservedObject var camera: CameraViewModel
    @ObservedObject var profile: ProfileViewModel
    @ObservedObject var explore: ExploreViewModel
    
    //@Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = true

    @State var offset: CGFloat = screenWidth //* 2
    
    @State var storiesPopup = false
    @State var vibesPopup = false
    
    var body: some View {
        ZStack{
            GeometryReader { proxy in
                let rect = proxy.frame(in: .global)
                
                Pager(tabs: tabs, rect: rect, offset: $offset) {
                    
                    HStack(spacing: 0){
                        ChatsView(profile: profile)
                        CameraView(camera: camera, profile: profile, hideBtn: $storiesPopup)
                        ExploreMainView(viewModel: explore, profile: profile)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .overlay(
                NavBar(offset: $offset, storiesPressed: $storiesPopup, vibesPressed: $vibesPopup)
                    .opacity(camera.image != nil ? 0 : 1)
                    .padding(.bottom, screenHeight * 0.03),
                alignment: .bottom
            )
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .edgesIgnoringSafeArea(.all)
            
            if storiesPopup {
                VStack{
                    Spacer()
                    MyStoriesDropDown(popup: true)
                        //.offset(x: storiesPopup ? 0 : -screenWidth)
                        //.animation(.easeInOut)
                        .padding(.bottom, 50)
                }
            }
        
            VibesPopup(pop: $vibesPopup)
                .padding(.bottom, 50)
        }
    }
}

//var tabs = ["Profile", "Chats", "Camera", "Explore", "Showcase"]
var tabs = ["Chats", "Camera", "Explore"]
