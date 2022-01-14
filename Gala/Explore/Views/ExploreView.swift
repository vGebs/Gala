//
//  ExploreView1.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: ExploreViewModel
        
    var body: some View {
        ScrollView(showsIndicators: false){
            MatchStoriesView(stories: $viewModel.matchStories)
                .offset(y: screenHeight * 0.01)
            MyDivider()
                .frame(width: screenWidth * 0.95, height: screenHeight / 800)
                .offset(y: screenHeight * 0.01)

            RecentlyJoinedView(viewModel: viewModel.recentlyJoinedViewModel)
            MyDivider()
                .frame(width: screenWidth * 0.95, height: screenHeight / 800)

            
            VibesView()
            //StoriesView2()
        }
    }
}

struct ExploreView1_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView(viewModel: ExploreViewModel())
            .preferredColorScheme(.dark)
    }
}

