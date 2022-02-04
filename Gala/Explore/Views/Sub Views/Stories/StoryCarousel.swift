//
//  TestSnapchat.swift
//  Gala
//
//  Created by Vaughn on 2022-01-27.
//

import SwiftUI

struct StoryCarousel: View {
    
    @ObservedObject var viewModel: StoriesViewModel
    
    @Binding var selectedVibe: VibeCoverImage
    @Binding var showVibe: Bool
    
    @State var selectedStory = 0
    @State var tag = 0
    
    var body: some View {
        ZStack {
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
                                    StoryView(viewModel:
                                                StoryViewModel(
                                                    pid: viewModel.vibesDict[selectedVibe.title]![tag].posts[selectedStory].pid,
                                                    name: viewModel.vibesDict[selectedVibe.title]![tag].name,
                                                    birthdate: viewModel.vibesDict[selectedVibe.title]![tag].birthdate,
                                                    uid: viewModel.vibesDict[selectedVibe.title]![tag].uid
                                                ), post: viewModel.vibesDict[selectedVibe.title]![tag].posts[selectedStory],
                                              profileImg: viewModel.vibesDict[selectedVibe.title]![tag].profileImg
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
