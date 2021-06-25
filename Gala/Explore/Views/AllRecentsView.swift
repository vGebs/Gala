//
//  AllRecentsView.swift
//  Gala
//
//  Created by Vaughn on 2021-06-11.
//

import SwiftUI

struct AllRecentsView: View {
    @Binding var allNewUsers: [ProfileModel]
    
    var body: some View {
        VStack {
    
            RoundedRectangle(cornerRadius: 2)
                .foregroundColor(.gray)
                .frame(width: screenWidth / 4, height: screenHeight / 400)
                .padding(.top, 15)
    
            ScrollView(showsIndicators: false){
                HStack{
                    Text("Recently Joined")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Spacer()
                }
                .padding(.top, 3)
                .frame(width: screenWidth * 0.9)
                
                ForEach(allNewUsers){ user in
                    SmallUserView(viewModel: SmallUserViewModel(profile: user))
                        .padding(.bottom, 3)
                        .frame(width: screenWidth)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct AllRecentsView_Previews: PreviewProvider {
    static var previews: some View {
        AllRecentsView(allNewUsers: .constant(arr2))
    }
}

//struct AllRecentsView: View {
//    @Binding var allNewUsers: [ProfileModel]
//
//    var body: some View {
//        ScrollView(showsIndicators: false){
//            VStack {
//                ForEach(allNewUsers){ user in
//                    SmallUserView(viewModel: RecentlyJoinedViewModel(profile: user))
//                        .padding(.bottom, 1.5)
//                        .padding(.top, 1.5)
//                        .frame(width: screenWidth)
//                }
//            }
//        }
//        .padding(.top, 20)
//        .preferredColorScheme(.dark)
//    }
//}
//
//struct AllRecentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllRecentsView(allNewUsers: .constant(arr2))
//    }
//}
