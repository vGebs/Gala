//
//  TestSnapchat.swift
//  Gala
//
//  Created by Vaughn on 2022-01-27.
//

import SwiftUI

struct StoryCarousel: View {
    var colors = [Color.buttonPrimary, Color.primary, Color.accent]
    
    let stories = [
        [Color.primary, Color.yellow], //acts as user with 2 posts
        [Color.buttonPrimary, Color.accent], //acts as user with 2 posts
        [Color.green, Color.gray, Color.yellow] //acts as user with 3 posts
    ]
    
    @ObservedObject var viewModel: StoriesViewModel
    
    @Binding var selectedVibe: VibeCoverImage
    @Binding var showVibe: Bool
    
    @State var selectedStory = 0
    @State var tag = 0
    
    //[Vibe title: [Users]]
    //in UserPostSimple -> each user has an array of posts
    //When the user runs out of posts, we need to go to the next user
    
    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .foregroundColor(.black)
            
            VStack {
                TabView(selection: $tag) {
                    ForEach(0..<viewModel.vibesDict[selectedVibe.title]!.count, id: \.self) { index in
                        GeometryReader { proxy -> AnyView in
                            
                            let minX = proxy.frame(in: .global).minX
                            let width = screenWidth
                            let progress = -minX / (width * 2)
                            var scale = progress > 0 ? (1 - progress) : (1 + progress)
                            scale = scale < 0.7 ? 0.7 : scale
                            
                            return AnyView (
                                
                                VStack {
//                                    ZStack {
//                                        RoundedRectangle(cornerRadius: 20)
//                                            .foregroundColor(stories[tag][selectedStory])
//                                    }
                                    StoryView(viewModel:
                                                StoryViewModel(
                                                    pid: viewModel.vibesDict[selectedVibe.title]![tag].posts[selectedStory].pid,
                                                    name: viewModel.vibesDict[selectedVibe.title]![tag].name,
                                                    birthdate: viewModel.vibesDict[selectedVibe.title]![tag].birthdate,
                                                    uid: viewModel.vibesDict[selectedVibe.title]![tag].uid
                                                ),
                                              vibeTitle: selectedVibe.title
                                    )
                                }
                                .frame(width: screenWidth, height: screenHeight)
                                .scaleEffect(scale)
                                .edgesIgnoringSafeArea(.all)
                                .tag(index)
                                .onTapGesture {
                                    withAnimation {
                                        if self.selectedStory + 1 < viewModel.vibesDict[selectedVibe.title]![tag].posts.count {
                                            self.selectedStory += 1
                                        } else {
                                            //animate slide
                                            if tag + 1 < viewModel.vibesDict[selectedVibe.title]!.count {
                                                withAnimation { tag += 1 }
                                                self.selectedStory = 0
                                            } else {
                                                withAnimation {
                                                    showVibe = false
                                                }
                                                self.selectedStory = 0
                                                self.tag = 0
                                            }
                                        }
                                    }
                                }
                                .onChange(of: tag, perform: { _ in
                                    self.selectedStory = 0
                                })
                            )
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
