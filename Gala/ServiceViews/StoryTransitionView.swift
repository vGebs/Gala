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
                        ZStack{
                            SnapCard(storyImg: vibesDict[selectedVibe.title]![userIndex].posts[postIndex].storyImage) //
                                .rotation3DEffect(yOffset > 50 ? .degrees(0) : .degrees(proxy.frame(in: .global).minX / -10), axis: (x: 0, y: 1, z: 0))
                                .onTapGesture {
                                    //Posts are done
                                    //userIndex = i
    
                                    if postIndex == vibesDict[selectedVibe.title]![userIndex].posts.count - 1{
                                        postIndex = 0
                                        
                                        //Users are done
                                        if userIndex == vibesDict[selectedVibe.title]!.count - 1{
                                            withAnimation {
                                                self.selectedVibe = VibeCoverImage(image: UIImage(), title: "")
                                                showVibe = false
                                                userIndex = 0
                                            }
                                        } else {
                                            //still users left
                                            withAnimation {
                                                userIndex += 1
                                            }
                                        }
                                    } else {
                                        //still posts left
                                        postIndex += 1
                                    }
                                }.gesture(DragGesture().onChanged({ value in
                                    if abs(value.translation.width) > 10 {
                                        userIndex = i
                                        postIndex = 0
                                    }
                                }))
                                
                                .tag(i)
                            
                            VStack {
                                Text("UserIndex: \(userIndex)")
                                if userIndex == i {
                                    Text("UserIndex == i")
                                }
                                Text("PostIndex: \(postIndex)")
                            }
                        }
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
                .frame(width: screenWidth)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.primary)
                .frame(width: screenWidth)
        }
    }
}
