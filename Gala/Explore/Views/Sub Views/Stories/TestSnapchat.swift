//
//  TestSnapchat.swift
//  Gala
//
//  Created by Vaughn on 2022-01-27.
//

import SwiftUI

struct TestSnapchat: View {
    var colors = [Color.buttonPrimary, Color.primary, Color.accent]
    
    let stories = [
        [Color.primary, Color.yellow],
        [Color.buttonPrimary, Color.accent],
        [Color.green, Color.gray, Color.yellow]
    ]
    
    //We need the selected vibe and the vibesdict so we can loop through the posts
//    @ObservedObject var viewModel: StoriesViewModel
//    @Binding var selectedVibe: ImageHolder
    
    @State var selectedStory = 0
    @State var tag = 0
    
    //@Binding var selectedVibe: ImageHolder
    
    @Binding var showVibe: Bool
    
    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .foregroundColor(.black)
            
            VStack {
                TabView(selection: $tag) {
                    ForEach(0..<stories.count, id: \.self) { index in
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
                                            .foregroundColor(stories[tag][selectedStory])
                                    }
                                }
                                .frame(width: screenWidth, height: screenHeight)
                                .scaleEffect(scale)
                                .edgesIgnoringSafeArea(.all)
                                .tag(index)
                                .onTapGesture {
                                    withAnimation {
                                        if self.selectedStory + 1 < stories[selectedStory].count {
                                            self.selectedStory += 1
                                        } else {
                                            //animate slide
                                            if tag + 1 < stories.count {
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
