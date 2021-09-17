//
//  StoriesView.swift
//  Gala
//
//  Created by Vaughn on 2021-09-12.
//

import SwiftUI

struct StoriesView: View {
    var body: some View {
        //ScrollView(showsIndicators: false) {
        VStack {
            HStack {
                Text("Currated Watchlist")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                
                Spacer()
            }
            .frame(width: screenWidth * 0.9)
            .padding(.leading)
            .padding(.trailing)
            
            HStack {
                StoryView()
                
                Spacer()
                StoryView()
            }
            
            HStack {
                StoryView()
                Spacer()
                
                StoryView()
            }
            
            HStack {
                StoryView()
                Spacer()
                
                StoryView()
            }
            
            HStack {
                StoryView()
                Spacer()
                
                StoryView()
            }
        }
        .frame(width: screenWidth * 0.9)
        //}
    }
}

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}
