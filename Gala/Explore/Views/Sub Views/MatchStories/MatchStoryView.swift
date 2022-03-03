//
//  MatchStoryView.swift
//  Gala
//
//  Created by Vaughn on 2022-03-03.
//

import SwiftUI

struct MatchStoryView: View {
    var posts: [Post]
    //var snapViewModel: SnapProtocol
    @State var counter: Int = 0
    @Binding var show: Bool
    
    var body: some View {
        ZStack {
            if posts[counter].storyImage != nil {
                Image(uiImage: posts[counter].storyImage!)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if counter == posts.count - 1{
                            //snapViewModel.openSnap(snap: snaps[counter])
                            show = false
                        } else {
                            //snapViewModel.openSnap(snap: snaps[counter])
                            counter += 1
                        }
                    }
            }
        }
    }
}
