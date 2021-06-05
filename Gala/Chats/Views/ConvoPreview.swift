//
//  ConvoPreview.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ConvoPreviewView: View {
    var profilePic: String = "me"
    var name: String = "Vaughn"
    var statusImage: String = "arrowtriangle.right"
    var status: String = "opened"
    var timeAgo: String = "2h"
    var statusColor: Color = .blue
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
                .shadow(color: .dropShadow, radius: 15, x: 10, y: 10)
                .shadow(color: .dropLight, radius: 15, x: -10, y: -10)
                .frame(width: screenWidth * 0.9, height: screenHeight / 12)

            HStack{
                Image(profilePic)
                    .resizable()
                    .frame(width: screenHeight / 17, height: screenHeight / 17)
                    .clipShape(Circle())
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    //.shadow(radius: 1)
                    .shadow(color: .dropShadow, radius: 15, x: 10, y: 10)
                    .shadow(color: .dropLight, radius: 15, x: -10, y: -10)
                
                VStack(alignment: .leading){
                    
                    Text(name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .offset(y: screenHeight / 100)

                    HStack {
                        Image(systemName: statusImage)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(statusColor)
                            .offset(y: screenHeight / 700)
                        
                        HStack {
                            Text(status)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(statusColor)
                            
                            Image(systemName: "circlebadge.fill")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 3, height: 3)
                            
                            Text(timeAgo)
                                .foregroundColor(.black)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                        }
                    }
                }
                
                Spacer()
            }
            .frame(width: screenWidth * 0.9, height: screenHeight / 14)
        }
        .frame(width: screenWidth, height: screenHeight / 12)
        .padding(.top, 5)
    }
}

struct ConvoPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ConvoPreviewView()
    }
}
