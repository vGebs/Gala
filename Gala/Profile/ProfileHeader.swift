//
//  ProfileHeader.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import Foundation
import SwiftUI

struct ProfileHeader: View {
        
    var body: some View {
        ZStack{
            Image("Mountains")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            Color.black.opacity(0.5)
            
            VStack {
                ZStack {
                    Image("me")
                        .resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fit)
                    
                    Circle().stroke(lineWidth: 3)
                        .foregroundColor(.white)
                        .frame(width: screenWidth / 3, height: screenWidth / 3, alignment: .center)
                    
                }
                .frame(width: screenWidth / 2.4, height: screenWidth / 2.4)
                
                VStack {
                    Text("Vaughn, 23")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .padding(.bottom, screenWidth / 200)
                    
                    HStack{
                        Image(systemName: "briefcase")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        
                        Text("Engineer")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .padding(.bottom, screenWidth / 200)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .light, design: .rounded))
                        
                        Text("Regina, SK")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                    }
                    .padding(.bottom, screenWidth / 100)
                }
                .offset(y: -screenWidth / 50)
                
                Spacer()
            }
        }
        .frame(width: screenWidth, height: screenHeight / 3)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
    }
}

struct ProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHeader()
            .previewDevice("iPhone 11")
//        ProfileHeader()
//            .previewDevice("iPhone 11 Pro")
//        ProfileHeader()
//            .previewDevice("iPhone 11 Pro Max")
//
//        ProfileHeader()
//            .previewDevice("iPhone 12")
//        ProfileHeader()
//            .previewDevice("iPhone 12 Pro")
//        ProfileHeader()
//            .previewDevice("iPhone 12 Pro Max")
//        ProfileHeader()
//            .previewDevice("iPhone 12 Mini")
    }
}
