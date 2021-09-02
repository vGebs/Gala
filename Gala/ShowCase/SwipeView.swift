//
//  SwipeView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-10.
//

import SwiftUI

struct SwipeView: View {
    
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ZStack{
            //ShowcaseCardView()
            RoundedRectangle(cornerRadius: 10)
                //.stroke(lineWidth: 2)
                .frame(width: screenWidth * 0.85, height: screenHeight * 0.6)
                .foregroundColor(.accent)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged{ value in
                            self.offset = value.translation
                        }
                        .onEnded{ value in
                            self.offset = .zero
                        }
                )
        }
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView()
    }
}
