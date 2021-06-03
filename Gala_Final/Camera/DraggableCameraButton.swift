//
//  DraggableCameraButton.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

//Drag button tutorial: https://medium.com/better-programming/swiftui-drag-gesture-2559cf255c5e

import SwiftUI

struct DraggableCameraButton: View {
    @State private var rectPosition = CGPoint(x: screenWidth / 2, y: screenHeight * 0.84)
    @State private var resetRectPosition = CGPoint(x: screenWidth / 2, y: screenHeight * 0.87)
    @State private var selectionBarRectPosition = CGPoint(x: screenWidth * 0.93, y : screenHeight * 0.11)
    
    @State private var profilePreview = CGPoint(x: -screenWidth / 3, y: screenHeight * 0.2)
    
    @GestureState private var isDragging = false
    
    @State private var isEnded = false
    @State private var outOfPosition = false
    @ObservedObject var camera: CameraViewModel
    @State var buttonColor = Color.yellow
    
    var body: some View {
       
        ZStack {
            ZStack {
                Capsule(style: .continuous)
                    .frame(width: screenWidth / 9, height: screenHeight / 10)
                    .foregroundColor(.black)
                    .opacity(0.2)
                VStack {
                    Spacer()
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(Font.system(size: 20, weight: .light))
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            camera.toggleCamera()
                        }
                    
                    Spacer()
                    Image(systemName: camera.flashEnabled ? "bolt" : "bolt.slash")
                        .font(Font.system(size: 20, weight: .light))
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            camera.flashEnabled.toggle()
                        }
                    Spacer()
                }
                .frame(width: screenWidth / 10, height: screenHeight / 10)
            }
            .position(selectionBarRectPosition)

            
            
            Image(systemName: "repeat.circle")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.blue)
                .opacity(outOfPosition ? 1 : 0)
                .frame(width: screenWidth / 12, height: screenWidth / 12)
                .position(resetRectPosition)
                .onTapGesture {
                    resetButtonPosition()
                }
            
            ZStack {
                Circle()
                    .fill(isDragging ? Color.black.opacity(0.3) : Color.black.opacity(0.6))
                    .frame(width: screenWidth / 5, height: screenWidth / 5)
                    
                Circle()
                    .stroke(lineWidth: 5)
                    .foregroundColor(buttonColor)
                    .frame(width: screenWidth / 5, height: screenWidth / 5)
            }
            .position(rectPosition)
            .onTapGesture {
                camera.takePic()
            }
            .gesture(DragGesture().onChanged({ value in
                self.rectPosition = value.location
                self.outOfPosition = true
                buttonColor = .blue
            }).updating($isDragging, body: { (value, state, trans) in
                state = true
            }).onEnded({ value in
                if value.location.y > screenHeight * 0.9 {
                    rectPosition.y = rectPosition.y - 90
                } else if value.location.y < screenHeight * 0.05 {
                    rectPosition.y = rectPosition.y + 70
                } else if value.location.x > screenWidth * 0.98 {
                    rectPosition.x = rectPosition.x - 20
                } else if value.location.x < screenWidth * 0.02{
                    rectPosition.x = rectPosition.x + 20
                }
                buttonColor = .yellow
            }))
            
            Button(action: { }){
                ProfilePreview()
            }
            .offset(x: -screenWidth / 2.5, y: -screenHeight / 2.35)
        }
            
    }
    
    func resetButtonPosition(){
        rectPosition = CGPoint(x: screenWidth / 2, y: screenHeight * 0.84)
        outOfPosition = false
    }
    
}

//struct DraggableCameraButton_Previews: PreviewProvider {
//    static var previews: some View {
//        DraggableCameraButton().previewDevice("iPhone 12 Mini")
//        DraggableCameraButton().previewDevice("iPhone 12 Pro")
//        DraggableCameraButton().previewDevice("iPhone 12 Pro Max")
//        //DraggableCameraButton().previewDevice("iPhone 8")
//        DraggableCameraButton().previewDevice("iPhone 8 Plus")
//    }
//}
