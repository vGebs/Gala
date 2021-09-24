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
                Image(systemName: "wand.and.stars.inverse")
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
                    .padding(.trailing)
            }
        }
        .frame(width: screenWidth * 0.9, height: screenHeight / 18)
    }
}

//struct PostSelector_Previews: PreviewProvider {
//    static var previews: some View {
//        PostSelector(selected: .constant("Just another manic monday.."), text: "Just another manic monday..")
//    }
//}
