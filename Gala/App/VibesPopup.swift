//
//  VibesPopup.swift
//  Gala
//
//  Created by Vaughn on 2022-01-13.
//

import SwiftUI

struct VibesPopup: View {
    @Binding var pop: Bool
    var body: some View {
        VStack {
            Spacer()
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
                    .opacity(0.4)
                    .frame(width: 140, height: 140)
                    .offset(x: pop ? 110 : 280)
                    .animation(.easeInOut)
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
                    .foregroundColor(.accent)
                    .frame(width: 140, height: 140)
                    .offset(x: pop ? 110 : 280)
                    .animation(.easeInOut)
            }
        }
    }
}
