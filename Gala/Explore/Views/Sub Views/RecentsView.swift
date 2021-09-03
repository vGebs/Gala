//
//  RecentsView.swift
//  Gala
//
//  Created by Vaughn on 2021-09-02.
//

import SwiftUI

struct RecentsView: View {
    @State var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .local)
            
            Pager(tabs: ["", "", ""], rect: rect, offset: $offset) {
                HStack(spacing: 15){
                    Color.red
                        .frame(width: screenWidth * 0.8)
                    
                    Color.black
                        .frame(width: screenWidth * 0.8)
                    
                    Color.blue
                        .frame(width: screenWidth * 0.8)
                }
                .frame(width: screenWidth * 3 * 0.9)
            }
        }
        .frame(width: screenWidth, height: screenHeight / 7.5)
    }
}

struct RecentsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentsView()
    }
}
