//
//  AllRecentsView.swift
//  Gala
//
//  Created by Vaughn on 2021-07-13.
//

import SwiftUI

struct AllRecentsView: View {
    
    @ObservedObject var viewModel: RecentlyJoinedViewModel
    
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
                
                ForEach(0..<viewModel.users.count, id: \.self){ i in
                    SmallUserView(viewModel: viewModel, user: viewModel.users[i])
                        .padding(.bottom, 3)
                        .frame(width: screenWidth)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

//struct AllRecentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllRecentsView(allNewUsers: .constant([
//            UserCore(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", ageMinPref: 18, ageMaxPref: 99, willingToTravel: 12, longitude: 44, latitude: 44),
//            UserCore(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", ageMinPref: 18, ageMaxPref: 99, willingToTravel: 12, longitude: 44, latitude: 44),
//            UserCore(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", ageMinPref: 18, ageMaxPref: 99, willingToTravel: 12, longitude: 44, latitude: 44),
//            UserCore(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", ageMinPref: 18, ageMaxPref: 99, willingToTravel: 12, longitude: 44, latitude: 44),
//        ]))
//    }
//}
