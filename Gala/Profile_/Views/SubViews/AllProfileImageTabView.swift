//
//  AllProfileImageTabView.swift
//  Gala
//
//  Created by Vaughn on 2022-07-13.
//

import Foundation
import SwiftUI

struct AllProfileImageTabView: View {
    var images: [UIImage]
    @State var startingAt: Int
    @Binding var show: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        show = false
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.buttonPrimary)
                            .font(.system(size: 27, weight: .regular, design: .rounded))
                        
                    }.padding(.trailing)
                }
                TabView(selection: $startingAt) {
                    ForEach(0..<images.count) { i in
                        Image(uiImage: images[i])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .edgesIgnoringSafeArea(.all)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page)
            }
        }
    }
}
