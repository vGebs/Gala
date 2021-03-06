//
//  NewcomerLikesDropDown.swift
//  Gala
//
//  Created by Vaughn on 2022-03-23.
//

import SwiftUI

struct NewcomerLikesDropDown: View {
    @State var expanded = false
    @State var initialHeight: CGFloat = 50
    
    @ObservedObject var viewModel: BasicLikesViewModel
            
    var body: some View {
        
        if viewModel.theyLikeMe.count > 0 {
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 15)
                    .stroke()
                    .foregroundColor(.accent)

                VStack {
                    Button(action: {
                        if expanded {
                            initialHeight = 50
                            expanded.toggle()
                        } else {
                            
                            initialHeight = ((screenWidth / 9) * CGFloat(viewModel.theyLikeMe.count + 1)) + (CGFloat(viewModel.theyLikeMe.count) * 25) //(63 * CGFloat(Double(viewModel.likes.count + 1)))
                            expanded.toggle()
                        }
                    }){
                        storiesPlaceholder
                    }
                    
                    if expanded {
                        MyDivider()
                            .frame(width: screenWidth * 0.9)
                        
                        ForEach(viewModel.theyLikeMe) { like in
                            SmallUserView(
                                viewModel: LikesViewModel(),
                                user: SmallUserViewModel(
                                    profile: like.userCore,
                                    img: like.profileImg
                                ),
                                distanceCalculator: DistanceCalculator(
                                    lng: like.userCore.searchRadiusComponents.coordinate.lng,
                                    lat: like.userCore.searchRadiusComponents.coordinate.lat
                                ),
                                demoMode: false,
                                width: screenWidth * 0.9
                            )
                        }

                        Spacer()
                    }
                }
            }
            .frame(width: screenWidth * 0.95, height: initialHeight) //+ addedHeight
            .animation(.easeIn(duration: 0.2))
        }
    }
    
    var storiesPlaceholder: some View {
        HStack {
            Image(systemName: "heart.fill")
                .foregroundColor(.primary)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .padding(.horizontal)
            
            if viewModel.theyLikeMe.count > 1 {
                Text("You have \(viewModel.theyLikeMe.count) likes")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
            } else if viewModel.theyLikeMe.count == 1 {
                Text("You have \(viewModel.theyLikeMe.count) like")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
            } else {
                Text("You have no stories")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
            }
            
            Spacer()
            if viewModel.theyLikeMe.count > 0 {
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.buttonPrimary)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding(.trailing)
            }
        }
        .padding(.vertical)
    }
    
    var addStoryButtonPlaceholder: some View {
        HStack {
            Image(systemName: "camera")
                .foregroundColor(.primary)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .padding(.horizontal)
            
            
            Text("Add to your story")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.accent)
            //.padding()
            
            Spacer()
            
            Image(systemName: "plus")
                .foregroundColor(.buttonPrimary)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding(.trailing)
        }
    }
}

