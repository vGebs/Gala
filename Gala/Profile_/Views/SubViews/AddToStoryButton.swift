//
//  AddToStoryButton.swift
//  Gala
//
//  Created by Vaughn on 2022-01-06.
//

import SwiftUI

struct AddToStoryButton: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .stroke()
                .foregroundColor(.accent)
            
            Button(action: {  }){
                HStack {
                    Image(systemName: "camera")
                        .foregroundColor(.primary)
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .padding(.horizontal)
                    
                    Text("Add to your story")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.accent)
                    //.padding()
                    
                    Spacer()
                    
                    Image(systemName: "plus")
                        .foregroundColor(.buttonPrimary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.trailing)
                }
            }
        }
        .frame(width: screenWidth * 0.95, height: CGFloat(50))
    }
}

struct AddToStoryButton_Previews: PreviewProvider {
    static var previews: some View {
        AddToStoryButton()
    }
}

