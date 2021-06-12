//
//  AnimationTest.swift
//  Gala
//
//  Created by Vaughn on 2021-06-08.
//

import SwiftUI

struct AnimationTest: View {
    @State private var offset: CGFloat = 0
    @State private var animate = true

    var body: some View {
        Text("Button")
            .offset(x: 0.0, y: offset)
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.5)) {
                    if animate {
                        self.offset = 100.0
                        animate = false
                    } else {
                        self.offset = 0
                        animate = true
                    }
                }
            }
    }
}

struct AnimationTest_Previews: PreviewProvider {
    static var previews: some View {
        AnimationTest()
    }
}
