//
//  AllRecentsView.swift
//  Gala
//
//  Created by Vaughn on 2021-07-13.
//

import SwiftUI

struct AllRecentsView: View {
    @Binding var allNewUsers: [UserSimpleModel]
    
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
                
//                ForEach(allNewUsers){ user in
//                    SmallUserView(viewModel: SmallUserViewModel(profile: user))
//                        .padding(.bottom, 3)
//                        .frame(width: screenWidth)
//                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct AllRecentsView_Previews: PreviewProvider {
    static var previews: some View {
        AllRecentsView(allNewUsers: .constant([
            UserSimpleModel(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", longitude: 44, latitude: 44),
            UserSimpleModel(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", longitude: 44, latitude: 44),
            UserSimpleModel(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", longitude: 44, latitude: 44),
            UserSimpleModel(uid: "123", name: "Vaughn", age: Date(), gender: "Male", sexuality: "Straight", longitude: 44, latitude: 44)
        ]))
    }
}
