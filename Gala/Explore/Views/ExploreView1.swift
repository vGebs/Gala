//
//  ExploreView1.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI

struct ExploreView1: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    @State var offset: CGFloat = 0
    
    var body: some View {
        ScrollView(showsIndicators: false){
            RecentlyJoinedView(newUsers: $viewModel.recentlyJoinedProfiles)
        }
    }
}

struct ExploreView1_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView1(viewModel: ExploreViewModel())
            .preferredColorScheme(.dark)
    }
}
