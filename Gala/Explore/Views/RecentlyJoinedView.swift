//
//  RecentlyJoinedView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI

struct RecentlyJoinedView: View {
    
    @StateObject var viewModel: RecentlyJoinedViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray)
            
            VStack {
                HStack {
                    Circle()
                        .stroke(Color.gray)
                        .frame(width: screenWidth / 6, height: screenWidth / 6)
                    
                    VStack {
                        HStack {
                            Button(action: {
                                //sheet presenting profile
                            }) {
                                Text("\(viewModel.profile.name), \(viewModel.profile.birthday.ageString())")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                            }
                            Spacer()
                        }
                        HStack {
                            Text(viewModel.profile.location)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.pink)

                            Spacer()
                        }
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    Button(action: {
                        //Like User
                    }){
                        Image(systemName: "plus")
                            .font(.system(size: 23, weight: .semibold, design: .rounded))
                    }
                }
                .padding(.leading)
                .padding(.top)
                .padding(.trailing)
                
                Spacer()
                
                TabView {
                    HStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray)
                            .frame(width: screenWidth / 3.8, height: screenHeight / 5.7)
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray)
                            .frame(width: screenWidth / 3.8, height: screenHeight / 5.7)
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray)
                            .frame(width: screenWidth / 3.8, height: screenHeight / 5.7)
                            //.frame(width: screenWidth / 3.3, height: screenHeight / 4.95)
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray)
                            .frame(width: screenWidth / 3.8, height: screenHeight / 5.7)
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray)
                            .frame(width: screenWidth / 3.8, height: screenHeight / 5.7)
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray)
                            .frame(width: screenWidth / 3.8, height: screenHeight / 5.7)
                            //.frame(width: screenWidth / 3.3, height: screenHeight / 4.95)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .frame(width: screenWidth * 0.9, height: screenHeight / 3.2)
    }
}

struct RecentlyJoinedView_Previews: PreviewProvider {
    static var previews: some View {
        RecentlyJoinedView(viewModel: RecentlyJoinedViewModel(profile: ProfileModel(name: "Vaughn", birthday: Date(), location: "Regina, Canada", userID: "123", bio: "Bioo", gender: "Male", sexuality: "Straight", job: "Engg", school: "U of R")))
            .preferredColorScheme(.dark)
    }
}
