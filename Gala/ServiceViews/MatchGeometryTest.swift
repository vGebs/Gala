//
//  MatchGeometryTest.swift
//  Gala
//
//  Created by Vaughn on 2022-03-04.
//

import SwiftUI

struct MatchGeometryTest: View {
    @State var show = false
    @Namespace var animation
    @State var draggedOffset: CGSize = .zero
    @State var scale: CGFloat = 1
    
    var response: CGFloat = 0.3
    var dampingFactor: CGFloat = 0.9
    var blendDuration: CGFloat = 0.01
    @State var showMenu = false
    var body: some View {
        ZStack {
            if show {
                Image("neon-light-frame")
                    .resizable()
                    .frame(width: screenWidth / 2, height: screenWidth / 2)
                    .scaledToFit()
            } else {
                Image("neon-light-frame")
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "Shape", in: animation)
                    .frame(width: screenWidth / 2, height: screenWidth / 2)
                    .onTapGesture {
                        withAnimation(.spring(response: response, dampingFraction: dampingFactor, blendDuration: blendDuration)) {
                            self.show.toggle()
                        }
                    }
            }
            
            if show {
                StoryTransitionView(yOffset: $draggedOffset.height)
                //RoundedRectangle(cornerRadius: 10)
                    .matchedGeometryEffect(id: "Shape", in: animation)
                    .scaleEffect(scale)
                    .offset(x: draggedOffset.width, y: draggedOffset.height)
                    .gesture(DragGesture().onChanged{ value in
                        
                        if value.translation.height > 50 {
                            self.draggedOffset = value.translation
                        }
                        
                        withAnimation(.spring(response: response, dampingFraction: dampingFactor, blendDuration: blendDuration)) {
                            if draggedOffset.height < 150 {
                                self.scale = 1 - abs(draggedOffset.height / 220)
                            }
                        }
                    }.onEnded{ value in
                        if value.translation.height > 70 && value.translation.height < 180{
                            withAnimation(.linear(duration: 0.2)) { //.spring(response: response, dampingFraction: dampingFactor, blendDuration: blendDuration)
                                self.show.toggle()
                                scale = 1
                            }
                            draggedOffset = .zero
                        } else {
                            withAnimation(.spring(response: response, dampingFraction: dampingFactor, blendDuration: blendDuration)) {
                                draggedOffset = .zero
                                scale = 1.0
                            }
                        }
                    })
                    .frame(width: screenWidth, height: screenHeight)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct MatchGeometryTest_Previews: PreviewProvider {
    static var previews: some View {
        MatchGeometryTest()
    }
}
