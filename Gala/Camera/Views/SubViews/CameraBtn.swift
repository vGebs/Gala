//
//  CameraBtn.swift
//  Gala
//
//  Created by Vaughn on 2022-01-11.
//

import SwiftUI
import Mantis

struct CameraBtn: View {
    @State var tap = false
    @ObservedObject var camera: CameraViewModel
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
                .opacity(0.2)
                .frame(width: screenWidth * 0.16, height: screenWidth * 0.16)
                .scaleEffect(tap ? 1.3 : 1)
                .scaleEffect(isLongPress ? 1.5 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6))
                .onTapGesture {
                    tap = true
                    camera.capturePhoto()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        tap = false
                        print("Tapped")
                    }
                }
                .gesture(longPress)
            
            Circle().stroke(lineWidth: tap ? 10 : 5)
                .foregroundColor(.white)
                .frame(width: isLongPress || tap ? 0 : screenWidth * 0.16, height: isLongPress || tap ? 0 : screenWidth * 0.16)
                .scaleEffect(tap ? 1.3 : 1)
                .scaleEffect(isLongPress ? 1.5 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6))
                .onTapGesture {
                    tap = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        tap = false
                        print("Tapped")
                    }
                }
                .gesture(longPress)
            
            if isLongPress {
                ringView
                    .frame(width: screenWidth * 0.3, height: screenWidth * 0.3)
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                            progress = 1 - (timeRemaining / 100)
                        }
                    }
            }
        }
    }
    
    @State var show = false
    @GestureState var isLongPress = false // will be true till tap hold
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.1)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .updating($isLongPress) { value, state, transaction in
                switch value {
                case .second(true, nil):
                    state = true
                    print("Start long press")
                    //show.toggle()
                    // side effect here if needed
                default:
                    break
                }
            }
            .onEnded { value in
                //show.toggle()
                print("Done long press")
                self.progress = 0
                self.timeRemaining = 100
            }
    }
    
    //@Binding var progress: Float
    
    @State var timeRemaining: Float = 100
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var progress: Float = 0
    
    var ringView: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
        }
    }
}
