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
    @ObservedObject var location: LocationViewModel
    
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
                            Text("\(user.uc.userBasic.name), \(user.uc.userBasic.birthdate.ageString())")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                            Text("\(location.city), \(location.country)")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    Spacer()
                    
                    Image(systemName: selected == user.uc.userBasic.uid ? "checkmark.square" : "square")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                        .padding(.trailing)
                }
            }
        }
        .frame(width: screenWidth * 0.9)
    }
}
