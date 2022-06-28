//
//  StoriesView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import SwiftUI

struct MatchStoriesView: View {
    //@Binding var stories: [StoryModel]
    @ObservedObject var viewModel: StoriesViewModel
    @State var showDemo: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.3.sequence.fill")
                    .foregroundColor(.primary)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                
                Text("Match Stories")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                Spacer()
                
                if showDemo {
                    Button(action: {
                        viewModel.clearMatchStoriesDemo()
                        self.showDemo = false
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).stroke()
                                .frame(width: screenWidth * 0.25, height: screenHeight * 0.03)
                                .foregroundColor(.buttonPrimary)
                            
                            Text("Clear demo")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .frame(width: screenWidth * 0.95, height: screenHeight * 0.02)
            
            if viewModel.matchedStories.count > 0 {
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(viewModel.matchedStories){ story in //stories, id: \.id
                            MatchedStoryView(storyVM: viewModel, story: story, demo: false)
                                .padding(.top, 2)
                        }
                    }
                }
                .frame(width: screenWidth * 0.95, height: screenHeight * 0.13)
            } else if showDemo {
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(viewModel.demoMatchedStories){ story in //stories, id: \.id
                            MatchedStoryView(storyVM: viewModel, story: story, demo: true)
                                .padding(.top, 2)
                        }
                    }
                }
                .frame(width: screenWidth * 0.95, height: screenHeight * 0.13)
            } else {
                VStack {
                    
                    Text("No match stories")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Button(action: {
                        viewModel.showMatchStoriesDemo()
                        self.showDemo = true
                    }){
                        DemoButtonView()
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
}
