//
//  CardView.swift
//  Gala
//
//  Created by Vaughn on 2021-08-31.
//

import SwiftUI

struct CardView: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
                .foregroundColor(.accent)
            
            Image("me")
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
            VStack{
                Spacer()
                HStack{
                    Text("Vaughn, 24")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
            }
            .shadow(radius: 15)
        }
        .frame(width: screenWidth * 0.85, height: screenHeight * 0.525)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
    }
}
