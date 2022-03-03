//
//  CircularLoadingView.swift
//  Gala
//
//  Created by Vaughn on 2022-03-03.
//

import SwiftUI

struct CircularLoadingView: View {
    @State private var shouldAnimate = false

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.35, to: 1)
                .stroke(style: StrokeStyle(lineCap: .round))
                .foregroundColor(.primary)
                .frame(width: screenWidth / 15, height: screenWidth / 15)
                .rotationEffect(shouldAnimate ? Angle(degrees: -360) : Angle(degrees: 0))
                .animation(Animation.easeInOut(duration: 1.5).repeatForever().delay(0.6))
            
            Circle()
                .trim(from: 0.35, to: 1)
                .stroke(style: StrokeStyle(lineCap: .round))
                .foregroundColor(.accent)
                .frame(width: screenWidth / 30, height: screenWidth / 30)
                .rotationEffect(shouldAnimate ? Angle(degrees: 360) : Angle(degrees: 0))
                .animation(Animation.easeInOut(duration: 1).repeatForever().delay(0.6))
        }
        .onAppear {
            shouldAnimate = true
        }
        .onDisappear {
            shouldAnimate = false
        }
    }
}

struct CircularLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        CircularLoadingView()
    }
}
