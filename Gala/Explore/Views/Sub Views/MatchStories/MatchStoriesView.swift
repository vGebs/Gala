//
//  StoriesView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import SwiftUI

struct MatchStoriesView: View {
    //@Binding var stories: [StoryModel]
    @ObservedObject var viewModel: StoriesViewModel
    var body: some View {
        if viewModel.matchedStories.count > 0 {
            VStack {
                HStack {
                    Image(systemName: "person.3.sequence.fill")
                        .foregroundColor(.primary)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                    
                    Text("Match Stories")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    Spacer()
                }
                .frame(width: screenWidth * 0.95, height: screenHeight * 0.02)
                
                ScrollView(.horizontal){
                    HStack{
                        ForEach(viewModel.matchedStories){ story in //stories, id: \.id
                            MatchedStoryView(storyVM: viewModel, story: story)
                                .padding(.top, 2)
                        }
                    }
                }
                .frame(width: screenWidth * 0.95, height: screenHeight * 0.13)                
            }
        }
    }
}
