//
//  AllRecentsView.swift
//  Gala
//
//  Created by Vaughn on 2021-07-13.
//

import SwiftUI

struct AllRecentsView: View {
    
    @ObservedObject var viewModel: RecentlyJoinedViewModel
    var demo: Bool
    
    var body: some View {
        VStack {
    
            RoundedRectangle(cornerRadius: 2)
                .foregroundColor(.accent)
                .frame(width: screenWidth / 4, height: screenHeight / 400)
                .padding(.top, 15)
    
            ScrollView(showsIndicators: false){
                HStack{
                    Text("Newcomers")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    Spacer()
                }
                .padding(.top, 3)
                .frame(width: screenWidth * 0.9)
                if demo {
                    ForEach(0..<viewModel.demoUsers.count, id: \.self){ i in
                        SmallUserView(
                            viewModel: viewModel,
                            user: viewModel.demoUsers[i],
                            distanceCalculator: DistanceCalculator(
                                lng: viewModel.demoUsers[i].profile!.searchRadiusComponents.coordinate.lng,
                                lat: viewModel.demoUsers[i].profile!.searchRadiusComponents.coordinate.lat),
                            demoMode: true,
                            width: screenWidth * 0.95
                        )
                            .padding(.bottom, 3)
                            .frame(width: screenWidth)
                    }
                } else {
                    ForEach(0..<viewModel.users.count, id: \.self){ i in
                        SmallUserView(
                            viewModel: viewModel,
                            user: viewModel.users[i],
                            distanceCalculator: DistanceCalculator(
                                lng: viewModel.users[i].profile!.searchRadiusComponents.coordinate.lng,
                                lat: viewModel.users[i].profile!.searchRadiusComponents.coordinate.lat),
                            demoMode: false,
                            width: screenWidth * 0.95
                        )
                            .padding(.bottom, 3)
                            .frame(width: screenWidth)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
