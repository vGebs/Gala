//
//  PicTakenView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct PicTakenView: View {
    @ObservedObject var camera: CameraViewModel
    @StateObject var sendVM = SendViewModel()
    @Binding var sendPressed: Bool
    
    @State var showTextEditor = false
    
    @State var text: String = ""
    @State var height: CGFloat = 30
    
    @State private var location: CGPoint = CGPoint(x: 0, y: screenHeight / 2)
    @State private var fingerLocation: CGPoint? // 1
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.location.y < screenHeight * 0.88 && value.location.y > screenHeight * 0.07{
                    self.location = value.location
                }
            }
    }
    
    var fingerDrag: some Gesture { // 2
        DragGesture()
            .onChanged { value in
                self.fingerLocation = value.location
            }
            .onEnded { value in
                self.fingerLocation = nil
            }
    }
    
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            if camera.image != nil {
                VStack{
                    Image(uiImage: camera.image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth, height: screenHeight * 0.91)
                        .cornerRadius(20)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.showTextEditor.toggle()
                        }
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            if let url = camera.videoURL {
                if !sendPressed {
                    VStack {
                        PlayerView(url: url)
                            .frame(height: screenHeight * 0.91)
                            .cornerRadius(20)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                self.showTextEditor.toggle()
                            }
                        
                        Spacer()
                    }
                }
            }
            
            if text.trimmingCharacters(in: .newlines) != "" && !showTextEditor {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                    Text(text)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                }
                .frame(width: screenWidth, height: height)
                .position(x: screenWidth / 2, y: location.y)
                .onTapGesture(perform: {
                    showTextEditor.toggle()
                })
                .gesture(simpleDrag.simultaneously(with: fingerDrag))
            }
            
            if showTextEditor {
                //ExpandingTextField(text: $text, height: $height)
                MultilineTextField("", text: $text, height: $height, onCommit: {
                    self.showTextEditor = false
                })
            }
            
            VStack{
                HStack{
                    Button(action: {
                        camera.deleteAsset()
                        AppState.shared.showSnapPreview = false
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                                .opacity(0.85)

                            RoundedRectangle(cornerRadius: 10).stroke()
                                .foregroundColor(.accent)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                        .frame(width: screenWidth / 11, height: screenWidth / 11)
                    }
                    .padding(.leading, screenWidth * 0.045)
                    .padding(.top, screenWidth * 0.13)
                    
                    Spacer()
                }
                Spacer()
                HStack{
                    Button(action: {
                        if !self.camera.photoSaved{
                            camera.saveAsset()
                        }
                    }){
                        ZStack {
                            Capsule()
                                .stroke()
                                .frame(width: screenWidth / 7, height: screenWidth / 10)
                                .foregroundColor(.buttonPrimary)

                            Image(systemName: camera.photoSaved ? "checkmark" : "tray.and.arrow.down")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(.leading, screenWidth * 0.01)
                    }
                    
                    Button(action: {
                        
                    }) {
                        ZStack {
                            Capsule()
                                .stroke()
                                .frame(width: screenWidth / 7, height: screenWidth / 10)
                                .foregroundColor(.buttonPrimary)

                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(.leading, screenWidth * 0.01)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.sendPressed = true
                        if sendVM.vibes.count == 0 ||
                            sendVM.currentPeriod != sendVM.getTimeOfDay() ||
                            sendVM.currentDay != Date().dayOfWeek()! ||
                            sendVM.currentDay == nil || sendVM.currentPeriod == nil {
                            self.sendVM.getPostableVibes()
                        }
                    }){
                        ZStack {
                            Capsule()
                                .stroke()
                                .frame(width: screenWidth / 3.5, height: screenWidth / 10)
                                .foregroundColor(.buttonPrimary)
                                //.opacity(0.8)
                            
                            HStack {
                                Text("Send")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.trailing, screenWidth * 0.01)
                    }
                    
                }
                .padding(.bottom, screenWidth / 13)
            }
            .sheet(isPresented: $sendPressed) {
                //SendViewTest(sendPressed: $sendPressed)
                SendView(text: $text, height: $height, yCoordinate: $location.y, isPresented: $sendPressed, camera: camera, viewModel: sendVM)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
