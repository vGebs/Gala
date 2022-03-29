//
//  ImagePicker.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import PhotosUI

//Tutorial Link: https://medium.com/dev-genius/swiftui-how-to-use-phpicker-photosui-to-select-image-from-library-5b74885720ec

struct ImagePicker: UIViewControllerRepresentable {
    
    //private var configuration: PHPickerConfiguration
    @Binding var isPresented: Bool
    @Binding var activeSheet: ActiveSheet?
    @Binding var pickerResult: [ImageModel]
    @Binding var numImages: Int
    var isProfilePic: Bool
    @Binding var didAddImg: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .livePhotos])
        
        configuration.selectionLimit = numImages
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, didAddImg: $didAddImg, isProfilePic: isProfilePic)
    }
    
    // Use a Coordinator to act as your PHPickerViewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        
        @Binding var didAddImg: Bool
        var isProfilePic: Bool
        private let parent: ImagePicker
        
        init(_ parent: ImagePicker, didAddImg: Binding<Bool>, isProfilePic: Bool) {
            self.parent = parent
            self._didAddImg = didAddImg
            self.isProfilePic = isProfilePic
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for image in results {
                if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (newImage, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            DispatchQueue.main.async {
                                self?.parent.pickerResult.append(ImageModel(image: newImage as! UIImage, index: self!.isProfilePic ? 0 : self!.parent.pickerResult.count + 1))
                                self?.didAddImg = true
                            }
                        }
                    }
                } else {
                    print("Loaded Assest is not an Image")
                }
            }
            
            parent.isPresented = false // Set isPresented to false because picking has finished.
            parent.activeSheet = nil
        }
    }
}
