//
//  UserStoryView.swift
//  Gala
//
//  Created by Vaughn on 2022-03-02.
//

import SwiftUI

struct UserStoryView: View {
    
    @State var showProfile = false
    //@Binding var img: UIImage?
    
    var body: some View {
        HStack {
            Button(action: { self.showProfile = true }){
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke()
                        .frame(width: screenWidth / 9, height: screenWidth / 9)
                        .foregroundColor(.blue)
                        .padding(.trailing)
                    
                    //if img == nil {
                        Image(systemName: "person.fill.questionmark")
                            .foregroundColor(Color(.systemTeal))
                            .frame(width: screenWidth / 20, height: screenWidth / 20)
                            .padding(.trailing)
                        
////                    } else {
//                        Image(uiImage: img!)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: screenWidth / 9.2, height: screenWidth / 9.2)
//                            .clipShape(RoundedRectangle(cornerRadius: 5))
//                            .padding(.trailing)
////                    }
                }
            }
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: screenHeight / 1500)
                    .foregroundColor(.accent)
                //Spacer()
                HStack {
                    Button(action: {}){
                        VStack {

                            HStack {
                                Text("Vaughn, 24")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("3km")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.accent)
                                Image(systemName: "circlebadge.fill")
                                    .font(.system(size: 5, weight: .regular, design: .rounded))
                                Text("2h")
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
    }
}
