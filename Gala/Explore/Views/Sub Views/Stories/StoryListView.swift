//
//  StoryListView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-27.
//

import SwiftUI

struct StoryListView: View {
    //var backgroundImg: UIImage
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ZStack {
                        Image("neon-light-frame")
                            .resizable()
                            .scaledToFill()
                            .frame(height: screenHeight * 0.7)
                        VStack {
                            Spacer()
                            
                            Text("Vibes")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Just Chillin'")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Tuesday Afternoon")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                            
                            HStack {
                                Spacer()
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
                                
                                Spacer()
                                
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
                                Spacer()
                            }
                            .frame(width: screenWidth)
                            .padding(.bottom, 5)
                            .padding(.top, 5)
                            
                            Text("These folks are on a chill vibe. See if you vibe with 'em!")
                                .font(.system(size: 13, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: screenWidth * 0.95)
                                .padding(.bottom, 5)
                        }
                    }
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListView()
    }
}
