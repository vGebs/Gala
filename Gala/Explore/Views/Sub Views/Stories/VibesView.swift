//
//  VibesView.swift
//  Gala
//
//  Created by Vaughn on 2022-01-04.
//

import SwiftUI

struct VibesView: View {
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "dot.radiowaves.up.forward")
                    .rotationEffect(.degrees(-90))
                    .foregroundColor(.primary)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                
                Text("Vibes")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                Spacer()
            }
            LazyVGrid(columns: columns) {
                ForEach((1...6).reversed(), id: \.self) { num in
                    RoundedRectangle(cornerRadius: 20)
                        .stroke()
                        .foregroundColor(.buttonPrimary)
                        .frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
                }
            }
        }
        .frame(width: screenWidth * 0.95)
    }
}

struct VibesView_Previews: PreviewProvider {
    static var previews: some View {
        VibesView()
    }
}
