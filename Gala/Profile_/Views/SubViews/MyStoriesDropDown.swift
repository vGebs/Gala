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
    
    @ObservedObject var viewModel: MyStoriesDropDownViewModel
    
    @State var addedHeight: CGFloat = 0
    
    var popup: Bool
    
    var body: some View {
        
        if viewModel.stories.count > 0 {
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
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
                            initialHeight = (63 * CGFloat(Double(viewModel.stories.count + 1)))
                            expanded.toggle()
                        }
                    }){
                        storiesPlaceholder
                    }
                    
                    if expanded {
                        MyDivider()
                            .frame(width: screenWidth * 0.9)
                        
                        ForEach(viewModel.stories) { story in
                            MyLikesDropDown(story: story, addedHeight: $addedHeight, viewModel: viewModel)
                        }

                        Spacer()
                    }
                }
            }
            .frame(width: screenWidth * 0.95, height: initialHeight + addedHeight)
            .animation(.easeIn(duration: 0.2))
        } else if viewModel.stories.count == 0 && popup {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
                
                RoundedRectangle(cornerRadius: 15)
                    .stroke()
                    .foregroundColor(.accent)
                
                storiesPlaceholder
            }
            .frame(width: screenWidth * 0.95, height: initialHeight + addedHeight)
        }
    }
    
    var storiesPlaceholder: some View {
        HStack {
            Image(systemName: "newspaper")
                .foregroundColor(.primary)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .padding(.horizontal)
            
            if viewModel.stories.count > 1 {
                Text("You have \(viewModel.stories.count) stories")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
            } else if viewModel.stories.count == 1 {
                Text("You have \(viewModel.stories.count) story")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
            } else {
                Text("You have no stories")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
            }
            
            Spacer()
            if viewModel.stories.count > 0 {
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.buttonPrimary)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding(.trailing)
            }
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
