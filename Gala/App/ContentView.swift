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
    
    @State var currentPage = 2
    @State var manager = ElegantPagesManager(startingPage: 2, pageTurnType: .regularDefault)
    
    //@Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = true

    var body: some View {
        ZStack {
//            if colorScheme == .dark {
//                Color.black
//            } else {
//                Color.white
//                VStack {
//                    Spacer()
//                    Color.black
//                        .frame(width: screenWidth, height: screenHeight * 0.13)
//                }
//            }
            //            Pages(currentPage: $currentPage, bounce: false){
            //                ProfileMainView()
            //                ChatsView()
            //                CameraView()
            //                ExploreView()
            //                ShowcaseView()
            //            }
            
            ElegantHPages(manager: manager){
                //ProfileView(viewModel: ProfileViewModel(name: "Vaughn", age: "23", mode: .profileStandard))
                ProfileMainView(viewModel: profile)
                BaseView()//ChatsView()
                CameraView(camera: camera)
                ExploreMainView(viewModel: explore)
                ShowcaseView()
            }
            .onPageChanged{ page in
                currentPage = page
                if currentPage == 2 {
                    camera.onCameraScreen = true
                } else {
                    camera.onCameraScreen = false
                }
            }
            
            NavBar(pageSelection: $currentPage, elegantPageSelection: $manager.currentPage)
                .offset(y: screenHeight * 0.44)
                .opacity(camera.picTaken ? 0 : 1)
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

