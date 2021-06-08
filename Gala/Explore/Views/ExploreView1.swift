//
//  ExploreView1.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI

struct ExploreView1: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HStack {
                        Text("Recently Joined")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                        Spacer()
                        
                        Button(action: {}) {
                            Text("See All")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top)
                    
                    TabView {
                        ForEach(viewModel.recentlyJoinedProfiles, id: \.id){ profile in
                            RecentlyJoinedView(viewModel: RecentlyJoinedViewModel(profile: profile))
                        }
                    }
                    .frame(height: screenHeight / 3)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: screenWidth * 0.9, height: screenHeight / 600)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
        }
    }
}

struct ExploreView1_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView1(viewModel: ExploreViewModel())
            .preferredColorScheme(.dark)
    }
}
