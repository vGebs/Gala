//
//  StoryView.swift
//  Gala
//
//  Created by Vaughn on 2022-01-25.
//

import SwiftUI

struct StoryView: View {
    @ObservedObject var viewModel: StoryViewModel
    var vibeTitle: String
    
    var body: some View {
        ZStack {
            if viewModel.img == nil {
                Color.black.edgesIgnoringSafeArea(.all)
                ProgressView()
            } else {
                Image(uiImage: viewModel.img!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: screenWidth, height: screenHeight)
            }
            
            VStack {
                storyHeader
                    .padding(.top, screenHeight * 0.05)
                    .padding(.leading, screenWidth * 0.03)
                Spacer()
                HStack {
                    Spacer()
                    storyFooter
                        .padding(.bottom)
                        .padding(.trailing)
                }
            }
        }
        .frame(width: screenWidth, height: screenHeight)
    }
    
    var storyHeader: some View {
        HStack {
            Image(systemName: "chevron.down")
                .foregroundColor(.buttonPrimary)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: screenWidth / 300, height: screenHeight / 20)
                .foregroundColor(.white)
            ZStack {
                if viewModel.profileImg == nil {
                    Image(systemName: "person.fill.questionmark")
                        .foregroundColor(Color(.systemTeal))
                        .frame(width: screenHeight / 20, height: screenHeight / 20)
                        .padding(.trailing)
                    
                } else {
                    Image(uiImage: viewModel.profileImg!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenHeight / 20, height: screenHeight / 20)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
        
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
                    .frame(width: screenHeight / 20, height: screenHeight / 20)
                    .foregroundColor(.buttonPrimary)
            }
            
            VStack{
                HStack {
                    Text(viewModel.timeSincePost)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Circle()
                        .frame(width: screenWidth / 70, height: screenWidth / 70)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.name), \(viewModel.age)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .frame(width: screenWidth * 0.7)
                
                HStack {
                    Text(vibeTitle)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(width: screenWidth * 0.7)
            }

            Spacer()
        }
    }
    
    var storyFooter: some View {
        Button(action: {
            viewModel.likePost()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: screenWidth * 0.3)
                    .foregroundColor(Color.black)
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
                    .foregroundColor(.buttonPrimary)
                    .frame(width: screenWidth * 0.3)
                
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Like")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(height: screenHeight * 0.05)
    }
}
