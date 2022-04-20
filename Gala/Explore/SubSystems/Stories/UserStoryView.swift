//
//  UserStoryView.swift
//  Gala
//
//  Created by Vaughn on 2022-03-02.
//

import SwiftUI
import CoreLocation

struct UserStoryView: View {
    
    @State var showProfile = false
    @State var showStory = false
    
    var user: UserPostSimple
    
    var body: some View {
        HStack {
            Button(action: { self.showProfile = true }){
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke()
                        .frame(width: screenWidth / 9, height: screenWidth / 9)
                        .foregroundColor(.blue)
                        .padding(.trailing)
                    
                    if user.profileImg == nil {
                        Image(systemName: "person.fill.questionmark")
                            .foregroundColor(Color(.systemTeal))
                            .frame(width: screenWidth / 20, height: screenWidth / 20)
                            .padding(.trailing)
                        
                    } else {
                        Image(uiImage: user.profileImg!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth / 9.2, height: screenWidth / 9.2)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.trailing)
                    }
                }
            }
            
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: screenHeight / 1500)
                    .foregroundColor(.accent)
                //Spacer()
                HStack {
                    Button(action: { showStory = true }){
                        VStack {

                            HStack {
                                Text("\(user.name), \(user.birthdate.ageString())")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("\(LocationService.shared.getTravelDistance_String(to: CLLocation(latitude: user.coordinates.lat, longitude: user.coordinates.lng)))")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.accent)
                                Image(systemName: "circlebadge.fill")
                                    .font(.system(size: 5, weight: .regular, design: .rounded))
                                Text(user.posts[user.posts.count - 1].timeSincePost)
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.accent)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(width: screenWidth * 0.95, height: screenWidth / 9)
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: ProfileViewModel(mode: .otherAccount, uid: user.uid), showProfile: $showProfile)
        })
        .sheet(isPresented: $showStory, content: {
            MultipleStoryView(posts: user.posts, show: $showStory)
        })
    }
}
