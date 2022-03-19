//
//  MyLikesDropDown.swift
//  Gala
//
//  Created by Vaughn on 2022-01-06.
//

import SwiftUI
import Combine

struct MyLikesDropDown: View {
    @State var height: CGFloat = 50
    @State var expanded = false
    
    @ObservedObject var viewModel: MyStoriesDropDownViewModel
    
    @ObservedObject var story: StoryViewable
    
    @Binding var addedHeight: CGFloat
        
    init(story: StoryViewable, addedHeight: Binding<CGFloat>, viewModel: MyStoriesDropDownViewModel){
        self.story = story
        self._addedHeight = addedHeight
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke()
                .foregroundColor(.accent)
                //.frame(height: height)
            VStack {
                
                storyPlaceHolder
                    .frame(height: 50)
                
                if expanded {
                    MyDivider()
                        .frame(width: screenWidth * 0.85)
                    ForEach(story.likes) { like in
                        SmallUserView(viewModel: LikesViewModel(), user: SmallUserViewModel(profile: like.userCore, img: like.profileImg), width: screenWidth * 0.85)
                    }
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.2))
        .frame(width: screenWidth * 0.9)
    }
    
    var storyPlaceHolder: some View {
        HStack{
            
            Button(action: {
                //View the story
            }){
                if story.storyImg == nil {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke()
                        .foregroundColor(.buttonPrimary)
                        .frame(width: 30, height: 30)
                        .padding(.horizontal)
                } else {
                    ZStack{
                        Image(uiImage: story.storyImg!)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .frame(width: 30, height: 30)
                            .clipped()
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .stroke()
                            .foregroundColor(.buttonPrimary)
                            .frame(width: 30, height: 30)
                            .padding(.horizontal)
                    }
                }
            }
            
            if story.likes.count == 0 {
                Text("\"\(story.title)\"")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
                
                Spacer()
                
                Button(action: {
                    //Delete story
                    viewModel.deleteStory(storyID: story.pid, vibe: story.title)
                    addedHeight -= 50
                }){
                    Image(systemName: "trash")
                        .foregroundColor(.buttonPrimary)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                
                Text("\(secondsToHoursMinutesSeconds(Int(story.pid.timeIntervalSinceNow)))")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
                    .padding(.trailing)
            }
            
            if story.likes.count > 0 {
                Button(action: {
                    //expandview
                    if expanded {
                        addedHeight -= height + (CGFloat(story.likes.count) * 19)
                        height = 50
                        expanded.toggle()
                        
                    } else {
                        height = (screenWidth / 9 * CGFloat(story.likes.count))
                        addedHeight += height + (CGFloat(story.likes.count) * 19)
                        expanded.toggle()
                    }
                }){
                    if story.likes.count == 1 {
                        Text("View \(story.likes.count) like")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.accent)
                    } else if story.likes.count > 1 {
                        Text("View all \(story.likes.count) likes")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.accent)
                    }
                }
                
                Spacer()
                
                if story.likes.count > 0 {
                    Button(action: {
                        //deleteStory
                        
                    }){
                        Image(systemName: "trash")
                            .foregroundColor(.buttonPrimary)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    
                    Button(action: {
                        //expandview
                        if expanded {
                            addedHeight -= height + (CGFloat(story.likes.count) * 19)
                            height = 50
                            expanded.toggle()
                            
                        } else {
                            height = (screenWidth / 9 * CGFloat(story.likes.count))
                            addedHeight += height + (CGFloat(story.likes.count) * 19)
                            expanded.toggle()
                        }
                    }){
                        Text("\(secondsToHoursMinutesSeconds(Int(story.pid.timeIntervalSinceNow)))")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.accent)
                        
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.buttonPrimary)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.trailing)
                    }
                    
                }
            }
        }
        .frame(height: height)
        .padding(.vertical, expanded ? 10 : 0)
    }
}

func secondsToHoursMinutesSeconds(_ seconds: Int) -> String { //(Int, Int, Int)
    
    if abs(((seconds % 3600) / 60)) == 0 {
        let secondString = "\(abs((seconds % 3600) / 60))s"
        return secondString
    } else if abs((seconds / 3600)) == 0 {
        let minuteString = "\(abs((seconds % 3600) / 60))m"
        return minuteString
    } else if abs(seconds / 3600) < 24{
        let hourString = "\(abs(seconds / 3600))h"
        return hourString
    } else {
        let dayString = "\(abs(seconds / 86400))d"
        return dayString
    }
}
