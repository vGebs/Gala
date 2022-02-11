//
//  MessageView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-10.
//

import SwiftUI

struct MessageView: View {
    var message: String
    var fromMe: Bool
    
    var body: some View {
        if fromMe {
            messageFromMe
        } else {
            messageToMe
        }
    }
    
    var messageFromMe: some View {
        HStack {
            Spacer()
            
            ZStack {
                Text(message)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
            .background(Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.leading, screenWidth * 0.3)
    }
    
    var messageToMe: some View {
        HStack {
            ZStack {
                Text(message)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
            .background(Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
        }
        .padding(.trailing, screenWidth * 0.3)
    }
}
