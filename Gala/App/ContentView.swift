//
//  ContentView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import ElegantPages
import Pages

struct ContentView: View {
    @ObservedObject var camera: CameraViewModel
    @ObservedObject var profile: ProfileViewModel
    @ObservedObject var explore: ExploreViewModel
    
    //@Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = true

    @Binding var offset: CGFloat
    
    var body: some View {
        ZStack {
            
            GeometryReader { proxy in
                let rect = proxy.frame(in: .global)
                
                ScrollableTabBar(tabs: tabs, rect: rect, offset: $offset) {
                    
                    HStack(spacing: 0){
                        ProfileMainView(viewModel: profile)
                        ChatsView()
                        CameraView(camera: camera)
                        ExploreMainView(viewModel: explore)
                        ShowcaseView()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .overlay(
                NavBar(offset: $offset)
                    .opacity(camera.picTaken ? 0 : 1)
                    .padding(.bottom, screenHeight * 0.03),
                alignment: .bottom
            )
//            VStack{
//                Spacer()
//                NavBar(offset: $offset)
//                    .opacity(camera.picTaken ? 0 : 1)
//                    .padding(.bottom, screenHeight * 0.03)
//            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(camera: CameraViewModel(volumeCameraButton: false))
//    }
//}

