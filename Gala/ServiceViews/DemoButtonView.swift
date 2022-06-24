//
//  DemoButtonView.swift
//  Gala
//
//  Created by Vaughn on 2022-06-23.
//

import Foundation
import SwiftUI

struct DemoButtonView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).stroke()
                .foregroundColor(.buttonPrimary)
                .frame(width: screenWidth * 0.35, height: screenHeight * 0.05)
            
            Text("Show Demo")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}
