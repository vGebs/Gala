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

    @State var offset: CGFloat = screenWidth //* 2
    
    @State var storiesPopup = false
    @State var vibesPopup = false
    
    @State var showVibe = false
    
    @State var scale: CGFloat = 1

    @Namespace var animation
    
    @State var selectedVibe = VibeCoverImage(image: UIImage(), title: "")
    @State var draggedOffset: CGSize = .zero
    
    var response: CGFloat = 0.3
    var dampingFactor: CGFloat = 0.9
    var blendDuration: CGFloat = 0.01
    
    @State var vibesDict: OrderedDictionary<String, [UserPostSimple]> = [:]

    var body: some View {
        ZStack{
            
            mainSwipeView
            
            if storiesPopup {
                storiesInfoPopupView
            }
            
            vibesPopupView
            
            if showVibe {
//                StoryTransitionView(yOffset: $draggedOffset.height, vibesDict: $vibesDict, selectedVibe: $selectedVibe, showVibe: $showVibe)
                //RoundedRectangle(cornerRadius: 10)
//                    .matchedGeometryEffect(id: selectedVibe.title, in: animation)
//                    .scaleEffect(scale)
//                    .offset(x: draggedOffset.width, y: draggedOffset.height)
//                    .gesture(DragGesture().onChanged{ value in
//
//                        if value.translation.height > 50 {
//                            self.draggedOffset = value.translation
//                        }
//
//                        withAnimation(.spring(response: response, dampingFraction: dampingFactor, blendDuration: blendDuration)) {
//                            if draggedOffset.height < 150 {
//                                self.scale = 1 - abs(draggedOffset.height / 220)
//                            }
//                        }
//                    }.onEnded{ value in
//                        if value.translation.height > 70 && value.translation.height < 180{
//                            withAnimation(.linear(duration: 0.2)) { //.spring(response: response, dampingFraction: dampingFactor, blendDuration: blendDuration)
//                                self.vibesDict = [:]
//                                self.showVibe.toggle()
//                                self.selectedVibe = VibeCoverImage(image: UIImage(), title: "")
//                                scale = 1
//                            }
//                            draggedOffset = .zero
//                        } else {
//                            withAnimation(.spring(response: response, dampingFraction: dampingFactor, blendDuration: blendDuration)) {
//                                draggedOffset = .zero
//                                scale = 1.0
//                            }
//                        }
//                    })
//                    .frame(width: screenWidth, height: screenHeight)
//                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    var mainSwipeView: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .global)
            
            Pager(tabs: tabs, rect: rect, offset: $offset) {
                
                HStack(spacing: 0){
                    ChatsView(viewModel: chat, profile: profile)
                    CameraView(camera: camera, profile: profile, hideBtn: $storiesPopup)
                    ExploreMainView(viewModel: explore, profile: profile, animation: animation, selectedVibe: $selectedVibe, showVibe: $showVibe, vibesDict: $vibesDict)
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
            //MyStoriesDropDown(popup: true)
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
