//
//  SendToSelector.swift
//  Gala
//
//  Created by Vaughn on 2022-02-17.
//

import SwiftUI

struct SendToSelector: View {
    var user: MatchedUserCore
    @Binding var selected: String
    
    var body: some View {
        HStack{
            ZStack {
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
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke()
                    .frame(width: screenWidth / 9, height: screenWidth / 9)
                    .foregroundColor(.blue)
                    .padding(.trailing)
            }
            
            VStack {
                Divider()
                HStack {
                    VStack {
                        HStack {
                            Text("\(user.uc.name), \(user.uc.age.ageString())")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                            Text("Poop Town")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    Spacer()
                    
                    Image(systemName: selected == user.uc.uid ? "checkmark.square" : "square")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                        .padding(.trailing)
                }
            }
        }
        .frame(width: screenWidth * 0.9)
    }
}
