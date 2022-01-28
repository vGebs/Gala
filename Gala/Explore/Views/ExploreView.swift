//
//  ExploreView1.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: ExploreViewModel
    //@Binding var showVibe: String?
    
    @Binding var selectedVibe: ColorStruct
    var animation: Namespace.ID
    
    @Binding var showVibe: Bool
    @Binding var offset: CGSize
    @Binding var scale: CGFloat
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false){
                MatchStoriesView(stories: $viewModel.matchStories)
                    .offset(y: screenHeight * 0.01)
                MyDivider()
                    .frame(width: screenWidth * 0.95, height: screenHeight / 800)
                    .offset(y: screenHeight * 0.01)

                RecentlyJoinedView(viewModel: viewModel.recentlyJoinedViewModel)
                MyDivider()
                    .frame(width: screenWidth * 0.95, height: screenHeight / 800)

                
                //VibesView(viewModel: viewModel.storiesViewModel, showVibe: $showVibe)
                TestSnapchatExpand(showVibe: $showVibe, offset: $offset, scale: $scale, selectedVibe: $selectedVibe, animation: animation)
            }
        }
    }
    
//    func onChanged(value: DragGesture.Value) {
//        
//        //only moves the view when user swipes down
//        if value.translation.height > 50 {
//            offset = value.translation
//            
//            //Scaling view
//            let height = screenHeight - 50
//            let progress = offset.height / height
//            
//            if 1 - progress > 0.5 {
//                scale = 1 - progress
//            }
//        }
//    }
//    
//    func onEnded(value: DragGesture.Value) {
//        
//        //resetting view
//        withAnimation {
//            
//            if value.translation.height > 170 {
//                showVibe = false
//            }
//            
//            offset = .zero
//            scale = 1
//        }
//    }
}
