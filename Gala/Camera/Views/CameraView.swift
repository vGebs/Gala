//
//  CameraView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct CameraView: View {
    
    @ObservedObject var camera: CameraViewModel
    let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.91))
    
    @State var sendPressed = false
    
    var body: some View{
        ZStack {
            SwiftUICamPreview(camera: camera, view: view)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture(count: 2) {
                    camera.toggleCamera()
                }
                .shadow(radius: 15)
            
            VStack {
                Spacer()
                Button(action: { self.camera.takePic()} ){
                    ZStack{
                        
                        RoundedRectangle(cornerRadius: 10)
                            //.frame(width: screenWidth / 9.5, height: screenWidth / 9.5)
                            .foregroundColor(.white)
                            .opacity(0.2)
                        
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 3)
                            .foregroundColor(.buttonPrimary)
                    }
                }
                .frame(width: screenWidth / 6.5, height: screenWidth / 6.5)
                .opacity(!camera.picTaken ? 1 : 0)
                .padding(.bottom, screenHeight * 0.08)
            }
            
            PicTakenView(camera: camera, sendPressed: $sendPressed)
                .opacity(camera.picTaken && !sendPressed ? 1 : 0)
            
            SendView(sendPressed: $sendPressed)
                .opacity(sendPressed ? 1 : 0)
            
            Color.white
                .edgesIgnoringSafeArea(.all)
                .opacity(camera.frontFlashActive && camera.currentCamera == .front ? 1 : 0)
        }
    }
}

