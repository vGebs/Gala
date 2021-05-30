//
//  ImageCropper.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import Mantis

//Documentation: https://github.com/guoyingtao/Mantis

//MARK: - ImageCropper Representable

struct ImageCropper: UIViewControllerRepresentable{
    typealias Coordinator = ImageCropperCoordinator
    @Binding var image: UIImage
    @Binding var isShowing: Bool
    @Binding var activeSheet: ActiveSheet?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImageCropper>) -> some Mantis.CropViewController {
        let cropper = Mantis.cropViewController(image: image)
        cropper.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 2 / 3)
        cropper.delegate = context.coordinator
        return cropper
    }
    
    func makeCoordinator() -> ImageCropperCoordinator {
        return ImageCropperCoordinator(image: $image, isShowing: $isShowing, activeSheet: $activeSheet)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

//MARK: - Coordinator

class ImageCropperCoordinator: NSObject, CropViewControllerDelegate{
    @Binding var image: UIImage
    @Binding var isShowing: Bool
    @Binding var activeSheet: ActiveSheet?
    
    init(image: Binding<UIImage>, isShowing: Binding<Bool>, activeSheet: Binding<ActiveSheet?>){
        self._image = image
        self._isShowing = isShowing
        self._activeSheet = activeSheet
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        image = cropped
        isShowing = false
        activeSheet = nil
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        isShowing = false
        activeSheet = nil
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) { }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) { }
    
    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) { }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) { }
}
