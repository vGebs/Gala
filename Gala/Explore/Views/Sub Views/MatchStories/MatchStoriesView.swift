//
//  StoriesView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import SwiftUI

struct MatchStoriesView: View {
    @Binding var stories: [StoryModel]
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.3.sequence.fill")
                    .foregroundColor(.primary)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                
                Text("Match Stories")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                Spacer()
            }
            .frame(width: screenWidth * 0.9)
            
            TabView{
                ForEach(0..<stories.count / 5){ i in //stories, id: \.id
                    HStack{
                        Button(action: {}){
                            MatchesStoryView(story: stories[i * 5])
                        }
                        MatchesStoryView(story: stories[i * 5 + 1])
                        MatchesStoryView(story: stories[i * 5 + 2])
                        MatchesStoryView(story: stories[i * 5 + 3])
                        MatchesStoryView(story: stories[i * 5 + 4])
                    }
                    .frame(width: screenWidth * 0.9)
                    .padding(.bottom, 10)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: screenWidth, height: screenHeight * 0.12)
        }
    }
}

struct MatchStoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MatchStoriesView(stories: .constant([StoryModel(story: UIImage(), name: "1", userID: "123"),
                                        StoryModel(story: UIImage(), name: "2", userID: "123"),
                                        StoryModel(story: UIImage(), name: "3", userID: "123"),
                                        StoryModel(story: UIImage(), name: "4", userID: "123"),
                                        StoryModel(story: UIImage(), name: "5", userID: "123"),
                                        StoryModel(story: UIImage(), name: "6", userID: "123"),
                                        StoryModel(story: UIImage(), name: "7", userID: "123"),
                                        StoryModel(story: UIImage(), name: "8", userID: "123")]))
    }
}
