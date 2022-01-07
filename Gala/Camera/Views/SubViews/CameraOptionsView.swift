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
                .foregroundColor(.white)
                .opacity(0.2)
            
            HStack{
                Spacer()
                
                Button(action: {
                    camera.toggleCamera()
                }){
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                
                Spacer()
                
                Button(action: {
                    camera.flashEnabled.toggle()
                }) {
                    Image(systemName: camera.flashEnabled ? "bolt.fill" : "bolt.slash.fill" )
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                
                
                Spacer()
            }
        }
        .frame(width: screenHeight / 12, height: screenWidth / 12)
    }
}
