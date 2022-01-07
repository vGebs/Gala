//
//  MyStoriesDropDown.swift
//  Gala
//
//  Created by Vaughn on 2022-01-06.
//

import SwiftUI

struct MyStoriesDropDown: View {
    @State var expanded = false
    @State var initialHeight: CGFloat = 50
    @State var stories = [
        StoryTest(storyID: 0, likes: [1,1,1,1,1,1]),
        StoryTest(storyID: 1, likes: [1,1,1,1]),
        StoryTest(storyID: 2, likes: [1,1,1,1,1,1,1,1,1]),
        StoryTest(storyID: 3, likes: [1,1,1]),
        StoryTest(storyID: 4, likes: [1,1,1,1,1,1,1,1]),
        StoryTest(storyID: 3, likes: [1,1,1]),
        StoryTest(storyID: 3, likes: [1,1,1]),
        StoryTest(storyID: 3, likes: [1,1,1]),
        StoryTest(storyID: 3, likes: [1,1,1])
    ]
    
    @State var addedHeight: CGFloat = 0
    
    var body: some View {
        
        if stories.count > 0 {
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .stroke()
                    .foregroundColor(.accent)
                
                VStack {
                    Button(action: {
                        if expanded {
                            initialHeight = 50
                            addedHeight = 0
                            expanded.toggle()
                        } else {
                            initialHeight = (60 * CGFloat(Double(stories.count + 1)))
                            expanded.toggle()
                        }
                    }){
                        storiesPlaceholder
                            
                    }
                    
                    if expanded {
                        MyDivider()
                            .frame(height: 3)
                        ForEach(stories) { story in
                            MyLikesDropDown(story: story, addedHeight: $addedHeight)
                        }

                        Spacer()
                    }
                }
            }
            .frame(width: screenWidth * 0.95, height: initialHeight + addedHeight)
            .animation(.easeIn(duration: 0.2))
        }
    }
    
    var storiesPlaceholder: some View {
        HStack {
            Image(systemName: "newspaper")
                .foregroundColor(.primary)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .padding(.horizontal)
            
            if stories.count > 1 {
                Text("You have \(stories.count) stories")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
            } else {
                Text("You have \(stories.count) story")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
            }
            
            Spacer()
            
            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                .foregroundColor(.buttonPrimary)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding(.trailing)
        }
        .padding(.vertical)
    }
    
    var addStoryButtonPlaceholder: some View {
        HStack {
            Image(systemName: "camera")
                .foregroundColor(.primary)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .padding(.horizontal)
            
            
            Text("Add to your story")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.accent)
            //.padding()
            
            Spacer()
            
            Image(systemName: "plus")
                .foregroundColor(.buttonPrimary)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding(.trailing)
        }
    }
}

struct MyStoriesDropDown_Previews: PreviewProvider {
    static var previews: some View {
        MyStoriesDropDown()
    }
}


struct StoryTest: Identifiable {
    var id = UUID()
    var storyID: Int
    var likes: [Int]
}

