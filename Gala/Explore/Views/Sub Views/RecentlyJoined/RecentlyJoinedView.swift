//
//  RecentlyJoinedView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-07.
//

import SwiftUI
import Combine

struct RecentlyJoinedView: View {
    
    @State var showAll = false
    @ObservedObject var viewModel: RecentlyJoinedViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "figure.wave")
                        .foregroundColor(.primary)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                    
                    Text("Newcomers")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    
                    Spacer()
                    
                    Button(action: {
                        self.showAll = true
                    }) {
                        Text("See All")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .frame(height: screenWidth * 0.1)
                }
                .frame(width: screenWidth * 0.95)
                .padding(.leading)
                .padding(.trailing)
                
                HStack {
                    TabView {
                        ForEach(0..<((viewModel.users.count + 1) / 2), id: \.self) { i in
                            VStack {
                                if i * 2 < viewModel.users.count {
                                    //SmallUserView(viewModel: SmallUserViewModel(profile: newUsers[i * 2]), matched: false)
                                    SmallUserView(viewModel: viewModel, user: viewModel.users[i * 2], width: screenWidth * 0.95)
                                        .padding(.bottom, 3)
                                }
                                
                                if i * 2 + 1 < viewModel.users.count {
                                    //SmallUserView(viewModel: SmallUserViewModel(profile: newUsers[i * 2 + 1]), matched: false)
                                    SmallUserView(viewModel: viewModel, user: viewModel.users[i * 2 + 1], width: screenWidth * 0.95)
                                    
                                }
                                
                                if i * 2 + 1 == viewModel.users.count {
                                    Spacer()
                                        .frame(height: 50)
                                }
                            }
                        }
                    }
                    .offset(y: -screenHeight * 0.017)
                    .frame(width: screenWidth, height: screenHeight / 7.5)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .frame(width: screenWidth, height: screenHeight / 7.5)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showAll, content: {
            AllRecentsView(viewModel: viewModel)
        })
        .preferredColorScheme(.dark)
    }
}

struct RecentlyJoinedView_Previews: PreviewProvider {
    static var previews: some View {
        RecentlyJoinedView(viewModel: RecentlyJoinedViewModel())
            .preferredColorScheme(.dark)
    }
}

struct MyDivider: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .frame(height: screenHeight / 800)
            .foregroundColor(.accent)
            .padding(.top, 5)
            .offset(y: -screenHeight * 0.017)
    }
}
