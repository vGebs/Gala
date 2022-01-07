//
//  CameraView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import AVFoundation
import MediaPlayer
import AVKit

struct CameraView: View {
    
    @ObservedObject var camera: CameraViewModel
    @ObservedObject var profile: ProfileViewModel
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.91))
    
    @State var sendPressed = false
    @State var isRecording = false
    @State var showProfile = false
    
    var body: some View{
        ZStack {
            SwiftUICamPreview(camera: camera, view: view)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture(count: 2) {
                    camera.toggleCamera()
                }
                .shadow(radius: 15)
            
            VStack {
                CameraViewHeader(showProfile: $showProfile, camera: camera)
                    .padding(.top, 5)
                Spacer()
                
//                tempRecordButton
//
//                Button(action: {camera.buildCamera()}){
//                    Text("Build cam")
//                }
//                .padding()
//
//                Button(action: { camera.tearDownCamera() }){
//                    Text("Tear down cam")
//                }
//                .padding()
                
                cameraButton
            }
            
            
            if let url = camera.videoURL {
                ZStack {
                    
                    //VideoPlayer(player: AVPlayer(url: URL(fileURLWithPath: url.path)))
                    VStack {
                        VideoPlayer(player: AVPlayer(url: URL(fileURLWithPath: url)))
                            .cornerRadius(20)
                            .frame(width: screenWidth, height: screenHeight * 0.91)
                        Spacer()
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack{
                        HStack{
                            Button(action: {
                                self.camera.deleteAsset()
                            }){
                                Image(systemName: "xmark")
                                    .foregroundColor(.buttonPrimary)
                                    .font(.system(size: 22, weight: .regular, design: .rounded))
                                    .padding()
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            
            if camera.image != nil {
                PicTakenView(camera: camera, sendPressed: $sendPressed)
            }
            
//            Color.white
//                .edgesIgnoringSafeArea(.all)
//                .opacity(camera.frontFlashActive && camera.currentCamera == .front ? 1 : 0)
        }
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: profile, showProfile: $showProfile)
        })
    }
    
    var tempRecordButton: some View {
        Button(action: {
            if self.camera.isRecording {
                self.camera.stopRecording()
            } else {
                self.camera.startRecording()
            }
        }){
            ZStack{
                RoundedRectangle(cornerRadius: 22)
                    .foregroundColor(.white)
                    .opacity(0.05)
                
                RoundedRectangle(cornerRadius: 22).stroke(lineWidth: 7)
                    .foregroundColor(.buttonPrimary)
            }
        }
        .frame(
            width: isRecording ? screenWidth / 4.5 : screenWidth / 6.5,
            height: isRecording ? screenWidth / 4.5 : screenWidth / 6.5)
        .opacity(camera.image == nil && camera.videoURL == nil ? 1 : 0)
        .padding(.bottom, screenHeight * 0.08)
    }
    
    @State var cameraButtonPressed = false
    
    var cameraButton: some View {
        Button(action: {
            self.camera.capturePhoto()
//            cameraButtonPressed = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                cameraButtonPressed = false
//            }
        }){
            ZStack{
//                Circle()
//                    .trim(from: 0, to: 0.25)
//                    .stroke(lineWidth: 3)
//                    .frame(width: screenWidth / 3.3)
//                    .opacity(cameraButtonPressed ? 1 : 0)
//                    .rotationEffect(Angle.degrees(300))
//                    .animation(.linear(duration: 0.1))
//                    .offset(y: -50)
                
                Circle()
                    .frame(width: screenWidth / 4)
                    .foregroundColor(.white)
                    .opacity(0.7)
                
                Circle()
                    .frame(width: screenWidth / 9)
                    .foregroundColor(.buttonPrimary)
                
                VStack{
                    HStack {
                        Spacer()
                        Circle()
                            .frame(width: screenWidth / 18)
                            .foregroundColor(.white)
                    }
                    .frame(width: screenWidth / 9)
                    Spacer()
                }
                .frame(width: screenWidth / 18, height: screenWidth / 18)
            }
        }
        .frame(
            width: isRecording ? screenWidth / 4.5 : screenWidth / 6.5,
            height: isRecording ? screenWidth / 4.5 : screenWidth / 6.5)
        .opacity(camera.image == nil ? 1 : 0)
        .padding(.bottom, screenHeight * 0.08)
    }
    
    var header: some View {
        HStack {
            
            VStack {
                Button(action: { self.showProfile = true }){
                    Image(systemName: "rectangle.stack.person.crop")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                .padding(.leading)
                Spacer()
            }
            
            Spacer()
            
            ZStack{
//                Image(systemName: "ticket")
//                    .font(.system(size: 100, weight: .thin, design: .rounded))
//                    .foregroundColor(.buttonPrimary)
                
                Image(systemName: "map.fill")
                    .font(.system(size: 30, weight: .thin, design: .rounded))
                    .foregroundColor(.primary)
                    
                Text("Gala")
                    .font(.system(size: 8, weight: .black, design: .rounded)) //size 15
                    .foregroundColor(.buttonPrimary)
            }
            .offset(y: -20)
            
            Spacer()
            
            CameraOptionsView(camera: camera)
                .padding(.trailing)
        }
        .padding(.top, screenHeight * 0.01)
        .frame(height: screenHeight / 12)
        .opacity(camera.image == nil ? 1 : 0)
    }
}
