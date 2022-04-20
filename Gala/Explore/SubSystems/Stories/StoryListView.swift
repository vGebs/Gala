//
//  StoryListView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-27.
//

import SwiftUI
import OrderedCollections

struct StoryListView: View {
    @Binding var show: Bool
//    var coverImg: UIImage
//    var vibeTitle: String
    @Binding var vibe: VibeCoverImage
    var timeFrame: String = "Tuesday Afternoon"
    var vibeDescription: String = "These folks are on a chill vibe. See if you vibe with 'em!"
    var stories: OrderedDictionary<String, [UserPostSimple]>
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    ZStack {
                        
                        Image(uiImage: vibe.image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: screenHeight * 0.7)
                        VStack {
                            Spacer()
                            
                            Text("Vibes")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            Text(vibe.title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(timeFrame)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                            
                            HStack {
                                Spacer()
                                
                                playButton
                                
                                Spacer()
                                
                                refreshButton
                                
                                Spacer()
                            }
                            .frame(width: screenWidth)
                            .padding(.bottom, 5)
                            .padding(.top, 5)
                            
                            Text(vibeDescription)
                                .font(.system(size: 13, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: screenWidth * 0.95)
                                .padding(.bottom, 5)
                        }
                    }
                    
                    if stories[vibe.title] != nil {
                        ForEach(stories[vibe.title]!) { user in
                            UserStoryView(user: user)
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                        }
                    }
                    
                    Spacer()
                    HStack {
                        Spacer()
                        if stories[vibe.title] != nil {
                            if stories[vibe.title]!.count > 1 {
                                if getNumberOfStoriesInVibe() > 1 {
                                    Text("\(stories[vibe.title]!.count) Users, \(getNumberOfStoriesInVibe()) Story")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.accent)
                                } else {
                                    Text("\(stories[vibe.title]!.count) Users, \(getNumberOfStoriesInVibe()) Stories")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.accent)
                                }
                            } else {
                                if getNumberOfStoriesInVibe() > 1 {
                                    Text("\(stories[vibe.title]!.count) User, \(getNumberOfStoriesInVibe()) Stories")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.accent)
                                } else {
                                    Text("\(stories[vibe.title]!.count) User, \(getNumberOfStoriesInVibe()) Story")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.accent)
                                }
                            }
                            
                        }
                    }
                    .frame(width: screenWidth * 0.9)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.black)
                        .frame(height: screenHeight * 0.03)
                }
            }
            
            VStack {
                HStack {
                    Button(action: { show = false }){
                        ZStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.black)
                                .font(.system(size: 30, weight: .semibold, design: .rounded))

                            Image(systemName: "arrow.backward.circle")
                                .foregroundColor(.buttonPrimary)
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                        }
                        
                    }
                    .padding()
                    Spacer()
                }
                .frame(width: screenWidth)
                .padding()
                Spacer()
            }
            .padding(.top)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var playButton: some View {
        Button(action: {}){
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Play")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }.frame(width: screenWidth * 0.4, height: screenHeight * 0.05)
    }
    
    var refreshButton: some View {
        Button(action: {}){
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "newspaper.fill") //goforward
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Post a Story")//Refresh
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(width: screenWidth * 0.4, height: screenHeight * 0.05)
    }
    
    func getNumberOfStoriesInVibe() -> Int {
        var final = 0
        
        if stories[vibe.title] != nil {
            for user in stories[vibe.title]! {
                for _ in user.posts {
                    final += 1
                }
            }
        }
        
        return final
    }
}
