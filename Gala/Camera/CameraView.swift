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
    
    var body: some View{
        ZStack {
            SwiftUICamPreview(camera: camera, view: view)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture(count: 2) {
                    camera.toggleCamera()
                }
                .shadow(radius: 15)
            
//            DraggableCameraButton(camera: camera)
//                //.offset(y: -30)
//                .opacity(!camera.picTaken ? 1 : 0)
            
            PicTakenView(camera: camera)
                .opacity(camera.picTaken ? 1 : 0)

            Color.white
                .edgesIgnoringSafeArea(.all)
                .opacity(camera.frontFlashActive && camera.currentCamera == .front ? 1 : 0)
        }
    }
}

