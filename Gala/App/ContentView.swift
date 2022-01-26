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
    @State var showVibe: String?
    
    @State var offset2: CGSize = .zero
    @State var scale: CGFloat = 1

    var body: some View {
        ZStack{
            
            mainSwipeView
            
            if storiesPopup {
                storiesPopupView
            }
            
            vibesPopupView
            
            if showVibe != nil {
                AnimatedCarousel(viewModel: explore.storiesViewModel, showVibe: $showVibe)
                    .offset(offset2)
                    .scaleEffect(scale)
                    .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnded(value:)))
            }
        }
    }

    func onChanged(value: DragGesture.Value) {
        //only moves view when swipes down
        if value.translation.height  > 70 {
            offset2 = value.translation
            
            let progress = offset2.height / screenHeight
            
            if 1 - progress > 0.5 {
                scale = 1 - progress
            }
        }
    }
    
    func onEnded(value: DragGesture.Value) {
        withAnimation(.default) {
            offset2 = .zero
            showVibe = nil
            scale = 1
        }
    }
    
    var mainSwipeView: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .global)
            
            Pager(tabs: tabs, rect: rect, offset: $offset) {
                
                HStack(spacing: 0){
                    ChatsView(profile: profile)
                    CameraView(camera: camera, profile: profile, hideBtn: $storiesPopup)
                    ExploreMainView(viewModel: explore, profile: profile, showVibe: $showVibe)
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
    }
    
    var storiesPopupView: some View {
        VStack{
            Spacer()
            MyStoriesDropDown(popup: true)
            //.offset(x: storiesPopup ? 0 : -screenWidth)
            //.animation(.easeInOut)
                .padding(.bottom, 50)
            
        }
    }
    
    var vibesPopupView: some View {
        VibesPopup(pop: $vibesPopup)
            .padding(.bottom, 50)
    }
}

//var tabs = ["Profile", "Chats", "Camera", "Explore", "Showcase"]
var tabs = ["Chats", "Camera", "Explore"]
