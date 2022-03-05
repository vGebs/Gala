//
//  StoryTransitionView.swift
//  Gala
//
//  Created by Vaughn on 2022-03-04.
//

import SwiftUI

struct StoryTransitionView: View {
    let users = [
        [Color.yellow, Color.buttonPrimary, Color.accent],
        [Color.orange, Color.buttonPrimary, Color.accent],
        [Color.primary, Color.buttonPrimary, Color.accent]
    ]
    let colors = [Color.primary, Color.buttonPrimary, Color.accent]
    @State var userIndex = 0
    @State var colorIndex = 0
    @Binding var yOffset: CGFloat
    
    var body: some View {
        TabView(selection: $userIndex) {
            ForEach(0..<users.count) { i in
                GeometryReader { proxy in
                    SnapCard(color: users[i][colorIndex])
                        .rotation3DEffect(yOffset > 50 ? .degrees(0) : .degrees(proxy.frame(in: .global).minX / -10), axis: (x: 0, y: 1, z: 0))
                        .onTapGesture {
                            if colorIndex == users[i].count - 1{
                                colorIndex = 0
                                
                                if userIndex == users.count - 1{
                                    withAnimation {
                                        userIndex = 0
                                    }
                                } else {
                                    withAnimation {
                                        userIndex += 1
                                    }
                                }
                            } else {
                                colorIndex += 1
                            }
                        }
                        .tag(i)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.black))
        .edgesIgnoringSafeArea(.all)
    }
}

struct SnapCard: View {
    var color: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(color)
            .frame(width: screenWidth, height: screenHeight)
    }
}

