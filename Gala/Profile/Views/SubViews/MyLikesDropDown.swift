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
    @ObservedObject var viewModel: MyStoriesDropDownViewModel
    
    var story: StoryAndLikes
    
    @Binding var addedHeight: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke()
                .foregroundColor(.accent)
            VStack {
                
                storyPlaceHolder
                
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
            
            Button(action: {
                //View the story
            }){
                Circle()
                    .stroke()
                    .frame(width: 30, height: 30)
                    .padding(.horizontal)
            }
            
            if story.likes.count == 0 {
                Text("\(story.likes.count) likes so far")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
                
                Spacer()
                
                Button(action: {
                    //Delete story
                    viewModel.deleteStory(storyID: story.storyID)
                    addedHeight -= 50
                }){
                    Image(systemName: "trash")
                        .foregroundColor(.buttonPrimary)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                
                Text("\(secondsToHoursMinutesSeconds(Int(story.storyID.timeIntervalSinceNow)))")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
                    .padding(.trailing)
            }
            
            if story.likes.count > 0 {
                Button(action: {
                    //expandview
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
                            addedHeight -= height - 50
                            height = 50
                            expanded.toggle()
                            
                        } else {
                            height = (50 * CGFloat(story.likes.count))
                            addedHeight += height - 50
                            expanded.toggle()
                        }
                    }){
                        Text("\(secondsToHoursMinutesSeconds(Int(story.storyID.timeIntervalSinceNow)))")
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
        .padding(.vertical, expanded ? 10 : 0)
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> String { //(Int, Int, Int)
        
//        print(String((seconds % 86400) / 3600) + " hours")
//        print(String((seconds % 3600) / 60) + " minutes")
//        print(String((seconds % 3600) % 60) + " seconds")
        
        if abs(((seconds % 3600) / 60)) == 0 {
            let secondString = "\(abs((seconds % 3600) / 60))s"
            return secondString
        } else if abs((seconds / 3600)) == 0 {
            let minuteString = "\(abs((seconds % 3600) / 60))m"
            return minuteString
        } else {
            let hourString = "\(abs(seconds / 3600))h"
            return hourString
        }
        
        //return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

