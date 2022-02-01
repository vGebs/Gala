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
    
    @State var showVibe = false
    
    @State var offset2: CGSize = .zero
    @State var scale: CGFloat = 1

    @Namespace var animation
    
    @State var selectedVibe = ImageHolder(image: UIImage())
    
    var body: some View {
        ZStack{
            
            mainSwipeView
            
            if storiesPopup {
                storiesInfoPopupView
            }
            
            vibesPopupView
            
            if showVibe {
                fullStoryPopup
            }
        }
    }

    var fullStoryPopup: some View {
        TestSnapchat(showVibe: $showVibe)
            .cornerRadius(20)
            .scaleEffect(scale)
            .matchedGeometryEffect(id: selectedVibe.id, in: animation)
            .offset(self.offset2)
            .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnded(value:)))
            .edgesIgnoringSafeArea(.all)
    }
    
    func onChanged(value: DragGesture.Value) {
        
        //only moves the view when user swipes down
        if value.translation.height > 50 {
            offset2 = value.translation
            
            //Scaling view
            let height = screenHeight - 50
            let progress = offset2.height / height
            
            if 1 - progress > 0.5 {
                scale = 1 - progress
            }
        }
    }
    
    func onEnded(value: DragGesture.Value) {
        
        //resetting view
        withAnimation {
            
            if value.translation.height > 120 {
                showVibe = false
            }
            
            offset2 = .zero
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
                    ExploreMainView(viewModel: explore, profile: profile, showVibe: $showVibe, selectedVibe: $selectedVibe, offset: $offset2, scale: $scale, animation: animation)
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
    
    var storiesInfoPopupView: some View {
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
