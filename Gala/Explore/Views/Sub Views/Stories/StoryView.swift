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
                    .padding(.top, screenHeight * 0.055)
                    .padding(.leading, screenWidth * 0.03)
                Spacer()
                HStack {
                    Spacer()
                    storyFooter
                        .padding()
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
    
    @State var liked = false
    
    var storyFooter: some View {
        HStack {
            Button(action: {
                //remove the individual story
            }) {
                buttonView(imageName: "xmark")
            }
            .frame(width: screenWidth * 0.12, height: screenWidth * 0.12)
            
            Spacer()
            
            Button(action: {
                if !liked {
                    viewModel.likePost()
                    liked = true
                }
                viewModel.likePost()
            }) {
                if !liked {
                    buttonView(imageName: "hand.thumbsup.fill")
                } else {
                    buttonView(imageName: "checkmark")
                }
            }
            .frame(width: screenWidth * 0.12, height: screenWidth * 0.12)
        }
    }
    
    struct buttonView: View {
        var imageName: String
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.black)
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
                    .foregroundColor(.buttonPrimary)
                
                Image(systemName: imageName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(width: screenWidth * 0.12, height: screenWidth * 0.12)
        }
    }
}
