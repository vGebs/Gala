//
//  StoryView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-23.
//

import SwiftUI

struct MatchesStoryView: View {
    var story: StoryModel
    
    var body: some View {
        VStack{
            RoundedRectangle(cornerRadius: 5)
                .stroke()
                .foregroundColor(.buttonPrimary)
                .frame(width: screenWidth / 7, height: screenWidth / 7)
            
            Text(story.name)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(width: screenWidth / 6)
    }
}

struct MatchesStoryView_Previews: PreviewProvider {
    static var previews: some View {
        MatchesStoryView(story: StoryModel(story: UIImage(), name: "Lawrence", userID: "123"))
    }
}
