//
//  ContentView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import OrderedCollections

struct ContentView: View {
    @ObservedObject var chat: ChatsViewModel
    @ObservedObject var camera: CameraViewModel
    @ObservedObject var profile: ProfileViewModel
    @ObservedObject var explore: ExploreViewModel
    
    //@Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    @State var draggedOffset: CGFloat = -screenWidth * 2
        
    @StateObject var navBarVM = NavBarViewModel()
    
    var body: some View {
        ZStack {
            mainSwipeView
            
            if chat.showChat {
                ChatView(showChat: $chat.showChat, userChat: $chat.userChat, viewModel: chat, messages: $chat.matchMessages, snaps: $chat.snaps, timeMatched: $chat.timeMatched)
                    .offset(x: draggedOffset)
                    .gesture(
                        DragGesture()
                            .onChanged{ val in
                                if val.translation.width < 0 && val.startLocation.x > screenWidth * 0.8 {
                                    withAnimation(Animation.interactiveSpring()) {
                                        self.draggedOffset = val.translation.width
                                    }
                                }
                            }
                            .onEnded { val in
                                if abs(val.translation.width) > screenWidth / 4 && val.startLocation.x > screenWidth * 0.8 {
                                    withAnimation(Animation.interactiveSpring()) {
                                        draggedOffset = -screenWidth * 2
                                        chat.showChat = false
                                    }
                                } else {
                                    withAnimation(Animation.interactiveSpring()) {
                                        draggedOffset = 0
                                    }
                                }
                            }
                    )
                    .onAppear{
                        withAnimation(Animation.interactiveSpring()) {
                            draggedOffset = 0
                        }
                    }
                    .onDisappear{
                        draggedOffset = -screenWidth * 2
                    }
            }
        }
    }
    
    var mainSwipeView: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .global)
            
            Pager(tabs: tabs, rect: rect, offset: $navBarVM.currentPage) {
                
                HStack(spacing: 0){
                    ChatsView(viewModel: chat, profile: profile)
                    CameraView(camera: camera, profile: profile)
                    ExploreMainView(viewModel: explore, profile: profile)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .overlay(
            NavBar(offset: $navBarVM.currentPage)
                .opacity(camera.image != nil ? 0 : 1)
                .padding(.bottom, screenHeight * 0.03),
            alignment: .bottom
        )
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .edgesIgnoringSafeArea(.all)
    }
}

//var tabs = ["Profile", "Chats", "Camera", "Explore", "Showcase"]
var tabs = ["Chats", "Camera", "Explore"]

