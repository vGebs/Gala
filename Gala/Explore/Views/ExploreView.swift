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
            StoriesView(stories: $viewModel.matchStories)
                .offset(y: screenHeight * 0.01)
            MyDivider()
                .offset(y: screenHeight * 0.01)

            RecentlyJoinedView(newUsers: $viewModel.recentlyJoinedProfiles)
            MyDivider()
        }
    }
}

struct ExploreView1_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView(viewModel: ExploreViewModel())
            .preferredColorScheme(.dark)
    }
}


//struct ExploreView1: View {
//    @ObservedObject var viewModel: ExploreViewModel
//
//    @State var offset: CGFloat = 0
//
//    var body: some View {
//        ScrollView(showsIndicators: false){
//            RecentlyJoinedView(newUsers: $viewModel.recentlyJoinedProfiles)
//        }
//    }
//}
//
//struct ExploreView1_Previews: PreviewProvider {
//    static var previews: some View {
//        ExploreView1(viewModel: ExploreViewModel())
//            .preferredColorScheme(.dark)
//    }
//}
