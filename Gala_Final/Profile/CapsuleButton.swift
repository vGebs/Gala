//
//  CapsuleButton.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct CapsuleButton: View {
    @Binding var liked: Bool
    
    var body: some View {
        ZStack {
            Capsule()
                .foregroundColor(.white)
                .shadow(radius: 20)
            
            HStack {
                Image(systemName: liked ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .padding(.trailing, 7)
    
                Text(liked ? "Liked" : "Like")
                    .foregroundColor(.red)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
            }
        }
        .frame(width: screenWidth * 0.3, height: screenHeight * 0.05, alignment: .center)
    }
}

struct CapsuleButton_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleButton(liked: .constant(true))
    }
}
