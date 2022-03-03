//
//  VibeView.swift
//  Gala
//
//  Created by Vaughn on 2022-01-20.
//

import SwiftUI

struct VibeView: View {
    var title: String
    var imageName: String = "squaresClouds"//"neon-light-frame"
    @State var expanded = false
    @Binding var showVibe: String?
    
    var body: some View {
        ZStack {
            vibePlaceHolder
        }
    }
    
    @State var width = (screenWidth * 0.95) * 0.48
    @State var height = (screenWidth * 0.95) * 0.48
    
    var vibePlaceHolder: some View {
        ZStack {
            
            Image(imageName)
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
                    Text(title)
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
        .frame(width: width, height: height)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            withAnimation {
                showVibe = title
            }
        }
    }
}
