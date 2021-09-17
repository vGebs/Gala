//
//  ExploreView1.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    @State var offset: CGFloat = 0
    
    var body: some View {
        ScrollView(showsIndicators: false){
            MatchStoriesView(stories: $viewModel.matchStories)
                .offset(y: screenHeight * 0.01)
            MyDivider()
                .offset(y: screenHeight * 0.01)

            RecentlyJoinedView(viewModel: viewModel.recentlyJoinedViewModel)
            MyDivider()
            
            StoriesView()
        }
    }
}

struct ExploreView1_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView(viewModel: ExploreViewModel())
            .preferredColorScheme(.dark)
    }
}

