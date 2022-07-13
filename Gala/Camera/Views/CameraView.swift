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
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    
    @State var isRecording = false
    @State var showProfile = false
        
    @State var verticalZoomOffset: CGSize = .zero
    
    var body: some View{
        ZStack {
            SwiftUICamPreview(camera: camera, view: view)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture(count: 2) {
                    camera.toggleCamera()
                }
                .shadow(radius: 15)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            verticalZoomOffset = gesture.translation
                            camera.zoomCamera(factor: -(verticalZoomOffset.height / 15))
                        }
                        .onEnded { _ in
                            verticalZoomOffset = .zero
                        }
                )
            
            VStack {
                CameraViewHeader(showProfile: $showProfile, camera: camera)
                    .padding(.top, 5)
                Spacer()
                
                CameraBtn(camera: camera)
                    .padding(.bottom, screenHeight * 0.08)
            }
        }
        .sheet(isPresented: $showProfile, content: {
            ProfileMainView(viewModel: profile, showProfile: $showProfile)
        })
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
