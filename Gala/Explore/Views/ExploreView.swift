//
//  ExploreView1.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var animation: Namespace.ID
    @Binding var selectedVibe: VibeCoverImage
    @Binding var showVibe: Bool
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false){
                MatchStoriesView(viewModel: viewModel.storiesViewModel)
                    .offset(y: screenHeight * 0.01)
                
                MyDivider()
                    .frame(width: screenWidth * 0.95, height: screenHeight / 800)
                    .offset(y: screenHeight * 0.01)

                RecentlyJoinedView(viewModel: viewModel.recentlyJoinedViewModel)
                
                MyDivider()
                    .frame(width: screenWidth * 0.95, height: screenHeight / 800)
                
                VibesPlaceHolder(viewModel: viewModel.storiesViewModel, animation: animation, selectedVibe: $selectedVibe, showVibe: $showVibe)
            }
        }
    }
}
