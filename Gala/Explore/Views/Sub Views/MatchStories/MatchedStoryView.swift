//
//  MatchedStoryView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-09.
//

import SwiftUI

struct MatchedStoryView: View {
    var story: UserPostSimple
    @ObservedObject var viewModel: MatchedStoryViewModel
    
    var body: some View {
        VStack{
            if viewModel.img == nil {
                RoundedRectangle(cornerRadius: 5)
                    .stroke()
                    .foregroundColor(.buttonPrimary)
                    .frame(width: screenWidth / 7, height: screenWidth / 7)
            } else {
                ZStack {
                    Image(uiImage: viewModel.img!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth / 7, height: screenWidth / 7)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .foregroundColor(.buttonPrimary)
                        .frame(width: screenWidth / 7, height: screenWidth / 7)
                }
            }
            
            Text(story.name)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(width: screenWidth / 6)
    }
}
