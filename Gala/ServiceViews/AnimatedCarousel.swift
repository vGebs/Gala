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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)

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
                                            .foregroundColor(stories[tag][self.selectedStory])
                                        VStack {
                                            Text("index: \(index)")
                                            Text("storyIndex: \(selectedStory)")
                                            Text("tag: \(tag)")
                                        }
                                    }
                                }
                                .frame(width: screenWidth, height: screenHeight)
                                .scaleEffect(scale)
                                .edgesIgnoringSafeArea(.all)
                                .tag(index)
                                .onTapGesture {
                                    withAnimation {
                                        if self.selectedStory + 1 < stories[index].count {
                                            self.selectedStory += 1
                                        } else {
                                            //animate slide
                                            if tag + 1 < stories.count {
                                                withAnimation { tag += 1 }
                                                self.selectedStory = 0
                                            } else {
                                                withAnimation { tag = 0 }
                                                self.selectedStory = 0
                                            }
                                        }
                                    }
                                }
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

struct AnimatedCarousel_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedCarousel()
    }
}
