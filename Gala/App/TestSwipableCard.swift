//
//  TestSwipableCard.swift
//  Gala
//
//  Created by Vaughn on 2022-03-29.
//

import SwiftUI

struct TestSwipableCardSystem: View {
    
    @State var show = false
    
    var body: some View {
        ZStack {
            Button(action: { show = true }){
                Text("ShowCard")
            }
            
            if show {
                TestSwipableCard(show: $show)
            }
        }
    }
}

struct TestSwipableCard: View {
    
    @Binding var show: Bool
    @State var draggedOffset: CGFloat = -screenWidth * 2
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .offset(x: draggedOffset)
                .foregroundColor(.primary)
                .frame(width: screenWidth, height: screenHeight * 0.9)
                .gesture(
                    DragGesture()
                        .onChanged{ val in
                            if val.translation.width < 0 && val.startLocation.x > screenWidth * 0.8 {
                                withAnimation(Animation.interactiveSpring()) {
                                    self.draggedOffset = val.translation.width
                                }
                            }
                        }
                        .onEnded { val in
                            if abs(val.translation.width) > screenWidth / 4 && val.startLocation.x > screenWidth * 0.8 {
                                withAnimation(Animation.interactiveSpring()) {
                                    draggedOffset = -screenWidth * 2
                                    show = false
                                }
                            } else {
                                withAnimation(Animation.interactiveSpring()) {
                                    draggedOffset = 0
                                }
                            }
                        }
                )
                .onAppear{
                    withAnimation(Animation.interactiveSpring()) {
                        draggedOffset = 0
                    }
                }
        }.onDisappear{
            draggedOffset = -screenWidth * 2
        }
    }
}
