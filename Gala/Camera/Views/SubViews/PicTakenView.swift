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
    
    var body: some View {
        ZStack{
            if camera.image != nil {
                VStack{
                    Image(uiImage: camera.image!)
                        .resizable()
                        .scaledToFill()
                    //.aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth, height: screenHeight * 0.91)
                        .cornerRadius(20)
                        .edgesIgnoringSafeArea(.all)
                    
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack{
                HStack{
                    Button(action: { camera.retakePic() }){
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                    }
                    .padding(.leading, screenWidth * 0.045)
                    .padding(.top, screenWidth * 0.13)
                    
                    Spacer()
                }
                Spacer()
                HStack{
                    Button(action: {
                        if !self.camera.picSaved{
                            camera.savePic()
                        }
                    }){
                        ZStack {
                            Capsule()
                                .stroke()
                                .frame(width: screenWidth / 7, height: screenWidth / 10)
                                .foregroundColor(.buttonPrimary)

                            Image(systemName: camera.picSaved ? "checkmark" : "tray.and.arrow.down")
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
                SendView(isPresented: $sendPressed, camera: camera, viewModel: sendVM)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//struct PicTakenView_Previews: PreviewProvider {
//    static var previews: some View {
//// 12
//        PicTakenView()
//            .previewDevice("iPhone 12")
//        PicTakenView()
//            .previewDevice("iPhone 12 Pro")
//        PicTakenView()
//            .previewDevice("iPhone 12 Pro Max")
//        PicTakenView()
//            .previewDevice("iPhone 12 Mini")
//// 11
//        PicTakenView()
//            .previewDevice("iPhone 11")
//        PicTakenView()
//            .previewDevice("iPhone 11 Pro")
//        PicTakenView()
//            .previewDevice("iPhone 11 Pro Max")
//// 8
//        PicTakenView()
//            .previewDevice("iPhone 8")
//        PicTakenView()
//            .previewDevice("iPhone 8 Plus")
//    }
//}