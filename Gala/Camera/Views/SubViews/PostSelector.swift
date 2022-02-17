//
//  PostSelector.swift
//  Gala
//
//  Created by Vaughn on 2021-09-23.
//

import SwiftUI

struct PostSelector: View {
    var selected: String
    var text: String
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke()
                .foregroundColor(.buttonPrimary)
            
            HStack{
                Image(systemName: text == "Add a private story" ? "shareplay.slash" : "shareplay")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.leading)
                
                Text(text)
                    .foregroundColor(.accent)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    //.padding(.leading)
                
                Spacer()
                
                Image(systemName: selected == text ? "checkmark.square" : "square")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                    .padding(text == "Add a private story" ? .leading : .trailing)
                
                if text == "Add a private story" {
                    Menu {
                        Text("Private stories will only be seen by your matches")
                    } label: {
                        Label("", systemImage: "exclamationmark.circle")
                            .foregroundColor(.buttonPrimary)
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
        }
        .frame(width: screenWidth * 0.9, height: screenHeight / 18)
    }
}

