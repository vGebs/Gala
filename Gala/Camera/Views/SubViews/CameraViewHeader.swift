//
//  CameraViewHeader.swift
//  Gala
//
//  Created by Vaughn on 2022-01-06.
//

import SwiftUI

struct CameraViewHeader: View {
    @Binding var showProfile: Bool
    @ObservedObject var camera: CameraViewModel
    
    var body: some View {
        ZStack {
            HStack {
                leftOptionButton
                Spacer()
                rightOptionButton
            }
            centerElement
        }
    }
    
    var leftOptionButton: some View {
        Button(action: { self.showProfile = true }){
            Image(systemName: "rectangle.stack.person.crop")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.buttonPrimary)
        }
        .padding(.leading)
    }
    
    var centerElement: some View {
        Text("Gala")
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundColor(.primary)
    }
    
    var rightOptionButton: some View {
        ZStack{
            HStack {
                Button(action: {
                    camera.flashEnabled.toggle()
                }){
                    Image(systemName: camera.flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                        .padding(.trailing, 7)
                }
                
                Button(action: {
                    camera.toggleCamera()
                }){
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
            }
        }
        .padding(.trailing)
    }
}
