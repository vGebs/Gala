//
//  StoryTransitionView.swift
//  Gala
//
//  Created by Vaughn on 2022-03-04.
//

import SwiftUI
import OrderedCollections

struct StoryTransitionView: View {
    let users = [
        [Color.yellow, Color.buttonPrimary, Color.accent],
        [Color.orange, Color.buttonPrimary, Color.accent],
        [Color.primary, Color.buttonPrimary, Color.accent]
    ]
    let colors = [Color.primary, Color.buttonPrimary, Color.accent]
    @State var userIndex = 0
    @State var postIndex = 0
    
    @Binding var yOffset: CGFloat
    @Binding var vibesDict: OrderedDictionary<String, [UserPostSimple]> //[String: [UserPostSimple]]
    @Binding var selectedVibe: VibeCoverImage
    @Binding var showVibe: Bool
    
    var body: some View {
        TabView(selection: $userIndex) {
            if vibesDict[selectedVibe.title] != nil {
                ForEach(0..<vibesDict[selectedVibe.title]!.count) { i in //vibesDict[selectedVibe.title]!.count
                    GeometryReader { proxy in
                        SnapCard(storyImg: vibesDict[selectedVibe.title]![i].posts[postIndex].storyImage) //
                            .rotation3DEffect(yOffset > 50 ? .degrees(0) : .degrees(proxy.frame(in: .global).minX / -10), axis: (x: 0, y: 1, z: 0))
                            .onTapGesture {
                                if postIndex == vibesDict[selectedVibe.title]![i].posts.count - 1{
                                    postIndex = 0
                                    
                                    if userIndex == vibesDict[selectedVibe.title]!.count - 1{
                                        withAnimation {
                                            //userIndex = 0
                                            postIndex = 0
                                            showVibe = false
                                            userIndex = 0
                                        }
                                    } else {
                                        withAnimation {
                                            postIndex = 0
                                            userIndex += 1
                                        }
                                    }
                                } else {
                                    postIndex += 1
                                }
                            }
                            .tag(i)
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.black))
        .edgesIgnoringSafeArea(.all)
    }
}

struct SnapCard: View {
    var storyImg: UIImage?
    //var color: Color
    var body: some View {
        if storyImg != nil {
            Image(uiImage: storyImg!)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.primary)
        }
    }
}

