//
//  AddMomentButtonView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import Combine

struct AddMomentButtonView: View {
    var text: TextType = .myShowcase
        
    enum TextType{
        case myMoment
        case myShowcase
    }
    
    private func getText(_ text: TextType) -> String {
        switch text{
        case .myMoment:
            return "My Moment"
        case .myShowcase:
            return "My Showcase"
        }
    }
    
    private func getWidth(text: TextType) -> Double{
        switch text{
        case .myMoment:
            return 3.7
        case .myShowcase:
            return 3.4
        }
    }
    
    var body: some View {
        ZStack {
            Capsule()
                .foregroundColor(.gray)
                .opacity(0.35)
            HStack {
                Image(systemName: "plus")
                    .foregroundColor(.blue)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                Text(getText(text))
                    .foregroundColor(.black)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
        }
        .frame(width: screenWidth / CGFloat(getWidth(text: text)), height: screenHeight / 35, alignment: .center)
    }
}

struct AddMomentButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddMomentButtonView()
    }
}
