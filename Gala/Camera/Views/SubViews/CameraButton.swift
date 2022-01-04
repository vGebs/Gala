//
//  CameraButton.swift
//  Gala
//
//  Created by Vaughn on 2021-10-23.
//

import SwiftUI

struct CameraButton: View {
    @GestureState var isLongPressed = false
    @State var isCompletedLongPress = false
    
    
    @GestureState var isDetectingLongPress = false
    @State var completedLongPress = false
    
    var longPress: some Gesture {
            LongPressGesture(minimumDuration: 3)
                .updating($isDetectingLongPress) { currentState, gestureState,
                        transaction in
                    gestureState = currentState
                    transaction.animation = Animation.default
                }
                .onEnded { finished in
                    
                    self.completedLongPress = finished
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.completedLongPress = false
                    }
                    print("LONGPRESS")
                }
        }
    
    var body: some View {
        
//        let longPressGesture = LongPressGesture(minimumDuration: 0.5, maximumDistance: 50)
//            .updating($isLongPressed) { newValue, state, transaction in
//                state = newValue
//            }
//            .onEnded { finished in
//                if finished {
//                    isCompletedLongPress = finished
//                }
//            }
//        ZStack{
//            Circle()
//                .frame(width: 100, height: 100)
//                .foregroundColor(.black)
//
//            Circle().stroke(lineWidth: isLongPressed || !isCompletedLongPress ? 3 : 1)
//                .foregroundColor(.red)
//        }
//        .frame(width: 100, height: 100)
//        .scaleEffect(isLongPressed ? 1.3: 1)
//        .gesture(longPressGesture)
        //        .animation(.default)
        
        ZStack {
            Circle()
                .foregroundColor(.black)
            Circle()
                .stroke(lineWidth: self.isDetectingLongPress ? 3 :
                             (self.completedLongPress ? 3 : 1)
                )
                .foregroundColor(.white)
//                .fill(self.isDetectingLongPress ?
//                      Color.red :
//                        (self.completedLongPress ? Color.green : Color.blue)
//                )
        }
        .frame(
            width: self.isDetectingLongPress ?
            150 :
                (self.completedLongPress ? 150 : 100),
            height: self.isDetectingLongPress ?
            150 : (self.completedLongPress ? 150 : 100),
            alignment: .center
        )
        .onLongPressGesture(minimumDuration: 1, pressing: { inProgress in
                print("In progress: \(inProgress)!")
            }) {
                print("Long pressed!")
            }
        //.gesture(longPress)
    }
}

struct CameraButton_Previews: PreviewProvider {
    static var previews: some View {
        CameraButton()
    }
}
