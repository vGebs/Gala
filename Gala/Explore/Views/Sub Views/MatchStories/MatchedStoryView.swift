//
//  MatchedStoryView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-09.
//

import SwiftUI

struct MatchedStoryView: View {
    @ObservedObject var story: UserPostSimple
    @State var showStory = false
    var body: some View {
        VStack{
            Button(action: {
                showStory = true
            }){
                if story.posts[story.posts.count - 1].storyImage == nil { //viewModel.img
                    ZStack{
                        CircularLoadingView()
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                            .foregroundColor(.buttonPrimary)
                            .frame(width: screenWidth / 7, height: screenWidth / 7)

                    }
                } else {
                    ZStack {
                        Image(uiImage: story.posts[story.posts.count - 1].storyImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth / 7, height: screenWidth / 7)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                            .foregroundColor(.buttonPrimary)
                            .frame(width: screenWidth / 7, height: screenWidth / 7)
                    }
                }
            }
            
            Text(story.name)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(width: screenWidth / 6)
        .sheet(isPresented: $showStory, content: {
            MultipleStoryView(posts: story.posts, show: $showStory)
        })
    }
}
