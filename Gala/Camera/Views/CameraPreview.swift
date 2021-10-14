//
//  CameraPreview.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

//struct SwiftUICamPreview: UIViewRepresentable {
//
//    @ObservedObject var camera: CameraViewModel
//    var view: UIView
//
//    func makeUIView(context: Context) ->  UIView {
//        return camera.makeUIView(view)
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        camera.updateUIView()
//    }
//}

struct SwiftUICamPreview: UIViewRepresentable {
    
    @ObservedObject var camera: CameraViewModel
    var view: UIView

    func makeUIView(context: Context) ->  UIView {
        return camera.makeUIView(view)
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}

