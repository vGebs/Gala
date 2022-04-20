//
//  VibeView.swift
//  Gala
//
//  Created by Vaughn on 2022-01-20.
//

import SwiftUI

struct VibeView: View {
    var vibe: VibeCoverImage
    
    var body: some View {
        ZStack {
            Image(uiImage: vibe.image)
                .resizable()
                .scaledToFill()
                .frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 4)
                .foregroundColor(.buttonPrimary)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(vibe.title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.trailing)
                        .padding(.vertical, 10)
                }
                .border(Color.buttonPrimary)
                .background(Color.white.opacity(0.15))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
