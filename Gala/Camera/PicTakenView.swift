//
//  PicTakenView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct PicTakenView: View {
    @ObservedObject var camera: CameraViewModel
    
    var body: some View {
        VStack{
            HStack{
                Button(action: { camera.retakePic() }){

                    Image(systemName: "xmark")
                        .font(.system(size: 25, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.leading, screenWidth / 14)
                        .padding(.top, screenWidth / 5.5)
                }
                
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
                            .frame(width: screenWidth / 7, height: screenWidth / 10)
                            .foregroundColor(Color.gray.opacity(0.7))

                        Image(systemName: camera.picSaved ? "checkmark" : "tray.and.arrow.down")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                }
                
                Spacer()
                
                Button(action: {  }){
                    ZStack {
                        Capsule()
                            .frame(width: screenWidth / 3.5, height: screenWidth / 10)
                            .foregroundColor(.yellow)
                            //.opacity(0.8)
                        
                        HStack {
                            Text("Send")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.trailing)
                }
                
            }
            .padding(.bottom, screenWidth / 13)
        }
        .edgesIgnoringSafeArea(.bottom)
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
