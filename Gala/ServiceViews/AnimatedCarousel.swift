//
//  AnimatedCarousel.swift
//  Gala
//
//  Created by Vaughn on 2022-01-25.
//

import SwiftUI

struct AnimatedCarousel: View {
    
    var colors = [Color.buttonPrimary, Color.primary, Color.accent]
    
    let stories = [
        [Color.primary, Color.yellow],
        [Color.buttonPrimary, Color.accent],
        [Color.green, Color.gray, Color.yellow]
    ]

    @State var selectedStory = 0
    @State var tag = 0
    
    @ObservedObject var viewModel: StoriesViewModel
    
    @Binding var showVibe: String?
    
    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .foregroundColor(.black)

            VStack {
                TabView(selection: $tag) {
                    if showVibe != nil {
                        ForEach(0..<viewModel.vibesDict[showVibe!]!.count, id: \.self) { index in
                            GeometryReader { proxy -> AnyView in
                                
                                let minX = proxy.frame(in: .global).minX
                                let width = screenWidth
                                let progress = -minX / (width * 2)
                                var scale = progress > 0 ? (1 - progress) : (1 + progress)
                                scale = scale < 0.7 ? 0.7 : scale
                                
                                return AnyView (
                                    
                                    VStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .foregroundColor(.primary)
                                            
                                            StoryView(viewModel:
                                                        StoryViewModel(
                                                            pid: viewModel.vibesDict[showVibe!]![index].posts[selectedStory].pid,
                                                            name: viewModel.vibesDict[showVibe!]![index].name,
                                                            birthdate: viewModel.vibesDict[showVibe!]![index].birthdate,
                                                            uid: viewModel.vibesDict[showVibe!]![index].uid
                                                        ),
                                                      post: viewModel.vibesDict[showVibe!]![index].posts[selectedStory],
                                                      profileImg: viewModel.vibesDict[showVibe!]![index].profileImg
                                            )
                                        }
                                    }
                                    .frame(width: screenWidth, height: screenHeight)
                                    .scaleEffect(scale)
                                    .edgesIgnoringSafeArea(.all)
                                    .tag(index)
                                    .onTapGesture {
                                        withAnimation {
                                            if self.selectedStory + 1 < viewModel.vibesDict[showVibe!]![index].posts.count {
                                                self.selectedStory += 1
                                            } else {
                                                //animate slide
                                                if tag + 1 < viewModel.vibesDict[showVibe!]!.count {
                                                    withAnimation { tag += 1 }
                                                    self.selectedStory = 0
                                                } else {
                                                    showVibe = nil
                                                }
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
