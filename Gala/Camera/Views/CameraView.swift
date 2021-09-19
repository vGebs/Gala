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
                header
                
                Spacer()
                
                cameraButton
            }

            PicTakenView(camera: camera, sendPressed: $sendPressed)
                .opacity(camera.picTaken ? 1 : 0)
            
            Color.white
                .edgesIgnoringSafeArea(.all)
                .opacity(camera.frontFlashActive && camera.currentCamera == .front ? 1 : 0)
        }
    }
    
    var cameraButton: some View {
        Button(action: { self.camera.takePic()} ){
            ZStack{
                
                RoundedRectangle(cornerRadius: 22)
                    .foregroundColor(.white)
                    .opacity(0.05)
                
                RoundedRectangle(cornerRadius: 22).stroke(lineWidth: 7)
                    .foregroundColor(.buttonPrimary)
            }
        }
        .frame(width: screenWidth / 6.5, height: screenWidth / 6.5)
        .opacity(!camera.picTaken ? 1 : 0)
        .padding(.bottom, screenHeight * 0.08)
    }
    
    var header: some View {
        HStack {
            
            VStack {
                Button(action: {}){
                    Image(systemName: "rectangle.stack.person.crop")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                .padding(.leading)
                Spacer()
            }
            
            Spacer()
            
            CameraOptionsView(camera: camera)
                .padding(.trailing)
        }
        .padding(.top, screenHeight * 0.01)
        .frame(height: screenHeight / 12)
        .opacity(!camera.picTaken ? 1 : 0)
    }
}

