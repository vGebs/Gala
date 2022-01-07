//
//  MyLikesDropDown.swift
//  Gala
//
//  Created by Vaughn on 2022-01-06.
//

import SwiftUI

struct MyLikesDropDown: View {
    @State var height: CGFloat = 50
    @State var expanded = false
    
    var story: StoryTest
    
    @Binding var addedHeight: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke()
                .foregroundColor(.accent)
            VStack {
                Button(action: {
                    if expanded {
                        addedHeight -= height - 50
                        height = 50
                        expanded.toggle()
                    } else {
                        height = (50 * CGFloat(story.likes.count))
                        addedHeight += height - 50
                        expanded.toggle()
                    }
                }){
                    storyPlaceHolder
                }
                if expanded {
                    MyDivider()
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.2))
        .frame(width: screenWidth * 0.9, height: height)
    }
    
    var storyPlaceHolder: some View {
        HStack{
            Circle()
                .stroke()
                .frame(width: 30, height: 30)
                .padding(.horizontal)
            
            Text("View all \(story.likes.count) likes")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.accent)
            
            Spacer()
            
            Text("2h")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.accent)
            
            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                .foregroundColor(.buttonPrimary)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding(.trailing)
        }
        .padding(.vertical, expanded ? 10 : 0)
    }
}


