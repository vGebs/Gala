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
    @State var showDemo = false
    @State var showAllDemo = false
    @State var demoMode = false
    
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
                    
                    if viewModel.users.count > 0 || viewModel.demoUsers.count > 0{
                        Button(action: {
                            if demoMode {
                                self.showAllDemo = true
                            } else {
                                self.showAll = true
                            }
                        }) {
                            Text("See All")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .frame(height: screenWidth * 0.1)
                    }
                }
                .frame(width: screenWidth * 0.95)
                .padding(.leading)
                .padding(.trailing)
                
                if viewModel.users.count > 0 {
                    HStack {
                        TabView {
                            ForEach(0..<((viewModel.users.count + 1) / 2), id: \.self) { i in
                                VStack {
                                    if i * 2 < viewModel.users.count {
                                        //SmallUserView(viewModel: SmallUserViewModel(profile: newUsers[i * 2]), matched: false)
                                        SmallUserView(
                                            viewModel: viewModel,
                                            user: viewModel.users[i * 2],
                                            distanceCalculator: DistanceCalculator(
                                                lng: viewModel.users[i * 2].profile!.searchRadiusComponents.coordinate.lng,
                                                lat: viewModel.users[i * 2].profile!.searchRadiusComponents.coordinate.lat
                                            ),
                                            demoMode: false,
                                            width: screenWidth * 0.95
                                        )
                                        .padding(.bottom, 3)
                                    }
                                    
                                    if i * 2 + 1 < viewModel.users.count {
                                        //SmallUserView(viewModel: SmallUserViewModel(profile: newUsers[i * 2 + 1]), matched: false)
                                        SmallUserView(
                                            viewModel: viewModel,
                                            user: viewModel.users[i * 2 + 1],
                                            distanceCalculator: DistanceCalculator(
                                                lng: viewModel.users[i * 2 + 1].profile!.searchRadiusComponents.coordinate.lng,
                                                lat: viewModel.users[i * 2 + 1].profile!.searchRadiusComponents.coordinate.lat
                                            ),
                                            demoMode: false,
                                            width: screenWidth * 0.95
                                        )
                                        
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
                } else if showDemo {
                    HStack {
                        TabView {
                            ForEach(0..<((viewModel.demoUsers.count + 1) / 2), id: \.self) { i in
                                VStack {
                                    if i * 2 < viewModel.demoUsers.count {
                                        //SmallUserView(viewModel: SmallUserViewModel(profile: newUsers[i * 2]), matched: false)
                                        SmallUserView(
                                            viewModel: viewModel,
                                            user: viewModel.demoUsers[i * 2],
                                            distanceCalculator: DistanceCalculator(
                                                lng: viewModel.demoUsers[i * 2].profile!.searchRadiusComponents.coordinate.lng,
                                                lat: viewModel.demoUsers[i * 2].profile!.searchRadiusComponents.coordinate.lat
                                            ), demoMode: true,
                                            width: screenWidth * 0.95
                                        )
                                        .padding(.bottom, 3)
                                    }
                                    
                                    if i * 2 + 1 < viewModel.demoUsers.count {
                                        //SmallUserView(viewModel: SmallUserViewModel(profile: newUsers[i * 2 + 1]), matched: false)
                                        SmallUserView(
                                            viewModel: viewModel,
                                            user: viewModel.demoUsers[i * 2 + 1],
                                            distanceCalculator: DistanceCalculator(
                                                lng: viewModel.demoUsers[i * 2 + 1].profile!.searchRadiusComponents.coordinate.lng,
                                                lat: viewModel.demoUsers[i * 2 + 1].profile!.searchRadiusComponents.coordinate.lat
                                            ), demoMode: true,
                                            width: screenWidth * 0.95
                                        )
                                        
                                    }
                                    
                                    if i * 2 + 1 == viewModel.demoUsers.count {
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
                } else {
                    VStack {
                        Text("No newcomers")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.accent)
                        
                        Button(action: {
                            demoMode = true
                            viewModel.getDemoUser()
                            showDemo = true
                        }) {
                            DemoButtonView()
                        }.padding(.bottom, 10)
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showAllDemo, content: {
            AllRecentsView(viewModel: viewModel, demo: true)
        })
        .sheet(isPresented: $showAll, content: {
            AllRecentsView(viewModel: viewModel, demo: false)
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
