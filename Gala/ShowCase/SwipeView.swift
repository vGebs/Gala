//
//  SwipeView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-10.
//

import SwiftUI

struct SwipeView: View {
    
    var body: some View {
        ZStack{
            //ShowcaseCardView()
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: screenWidth * 0.85, height: screenHeight * 0.6)
                .foregroundColor(.accent)
        }
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView()
    }
}
