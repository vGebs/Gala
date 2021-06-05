//
//  GalaProAdvertisement.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct GalaProAdvertisement: View {
    var body: some View {
        
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.red.opacity(0.6))
                    .shadow(color: .dropShadow, radius: 15, x: 10, y: 10)
                    .shadow(color: .dropLight, radius: 15, x: -10, y: -10)
                    .frame(width: screenWidth / 2.2, height: screenHeight / 7)
                        
                VStack {
                    Text("Get More Dates")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        
                    Text("Let people really see you by boosting your profile")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.offWhite)
                        .padding(.leading)
                        .padding(.trailing)
                }
                .padding(.top, screenHeight * 0.03)
                    
                Image("Hearts")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(y: -screenHeight * 0.07)
                    .frame(width: screenWidth / 3.5)
                        
            }
            .frame(width: screenWidth / 2.2, height: screenHeight / 7)
            Spacer()
        
    }
}

struct GalaProAdvertisement_Previews: PreviewProvider {
    static var previews: some View {
        GalaProAdvertisement()
    }
}
