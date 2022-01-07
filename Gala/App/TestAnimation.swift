//
//  TestAnimation.swift
//  Gala
//
//  Created by Vaughn on 2022-01-06.
//

import SwiftUI

struct TestAnimation: View {
    
    @State var expanded = false
    @State var height: CGFloat = 100
    @State var width: CGFloat = 100
    
    var body: some View {
        
        Button(action: {
            if expanded {
                height = 100
                width = 100
                expanded.toggle()
            } else {
                height = screenHeight
                width = screenWidth
                expanded.toggle()
            }
        }) {
            ZStack{
                RoundedRectangle(cornerRadius: 25)
                    //.stroke()
                    .foregroundColor(.blue)
                    .frame(width: width, height: height)
                
//                RoundedRectangle(cornerRadius: 20)
//                    .foregroundColor(.pink)
//                    .frame(width: 70, height: 70)
            }
            //.scaleEffect(scale)
            .animation(.easeIn(duration: 0.3)) //.linear(duration: 0.3)
        }
    }
}

struct TestAnimation_Previews: PreviewProvider {
    static var previews: some View {
        TestAnimation()
    }
}
