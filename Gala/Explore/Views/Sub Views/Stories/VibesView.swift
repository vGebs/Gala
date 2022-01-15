//
//  VibesView.swift
//  Gala
//
//  Created by Vaughn on 2022-01-04.
//

import SwiftUI
import Combine

struct VibesView: View {
    @ObservedObject var viewModel: StoriesViewModel

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
                Button(action: {
                    viewModel.fetch()
                }){
                    Text("Fetch")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
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
