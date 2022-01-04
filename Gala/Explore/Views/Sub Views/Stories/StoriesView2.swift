//
//  StoriesView2.swift
//  Gala
//
//  Created by Vaughn on 2022-01-04.
//

import SwiftUI

struct StoriesView2: View {
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    
    var body: some View {
        
        LazyVGrid(columns: columns) {
            ForEach((1...10).reversed(), id: \.self) { num in
                Image("me")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .cornerRadius(15)
            }
        }
        .frame(width: screenWidth * 0.9)
    }
}

struct StoriesView2_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView2()
    }
}
