//
//  CameraOptionsView.swift
//  Gala
//
//  Created by Vaughn on 2021-09-19.
//

import SwiftUI

struct CameraOptionsView: View {
    @ObservedObject var camera: CameraViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.white)
                .opacity(0.05)
            
            RoundedRectangle(cornerRadius: 15).stroke()
                .foregroundColor(.primary)
            VStack{
                Spacer()
                
                Button(action: {
                    //camera.toggleCamera()
                    
                }){
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                
                Spacer()
                
                Button(action: {
                    //camera.flashEnabled.toggle()
                    
                }) {
                    Image(systemName: "bolt.fill") //camera.flashEnabled ?  : "bolt.slash.fill"
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                
                
                Spacer()
            }
        }
        .frame(width: screenWidth / 12, height: screenHeight / 12)
    }
}
