//
//  MatchedStoryView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-09.
//

import SwiftUI

struct MatchedStoryView: View {
    @ObservedObject var storyVM: StoriesViewModel
    @ObservedObject var story: UserPostSimple
    var body: some View {
        VStack{
            Button(action: {
                //when we click on the story, we need to fetch the first img from core data
                storyVM.getStoryImage(uid: story.uid, pid: story.posts[0].pid)
                
                storyVM.currentStory = story.id
                storyVM.showMatchStory = true
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
        .sheet(isPresented: $storyVM.showMatchStory, content: {
            InstaStoryView(storyData: storyVM, mode: .match)
        })
    }
}
