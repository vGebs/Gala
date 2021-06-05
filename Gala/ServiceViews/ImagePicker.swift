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
        Coordinator(self)
    }
    
    // Use a Coordinator to act as your PHPickerViewControllerDelegate
    class Coordinator: PHPickerViewControllerDelegate {
        
        private let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            print(results)
            
            for image in results {
                if image.itemProvider.canLoadObject(ofClass: UIImage.self)  {
                    image.itemProvider.loadObject(ofClass: UIImage.self) { (newImage, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            DispatchQueue.main.async {
                                self.parent.pickerResult.append(ImageModel(image: newImage as! UIImage))
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


//struct ImagePicker: UIViewControllerRepresentable {
//
//    //private var configuration: PHPickerConfiguration
//    @Binding var isPresented: Bool
//    @Binding var activeSheet: ActiveSheet?
//    @Binding var pickerResult: [UIImage?]
//    var numImages: Int
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .any(of: [.images, .livePhotos])
//
//        configuration.selectionLimit = numImages
//
//        let controller = PHPickerViewController(configuration: configuration)
//        controller.delegate = context.coordinator
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // Use a Coordinator to act as your PHPickerViewControllerDelegate
//    class Coordinator: PHPickerViewControllerDelegate {
//
//        private let parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            print(results)
//
//            for image in results {
//                if image.itemProvider.canLoadObject(ofClass: UIImage.self)  {
//                    image.itemProvider.loadObject(ofClass: UIImage.self) { (newImage, error) in
//                        if let error = error {
//                            print(error.localizedDescription)
//                        } else {
//                            self.parent.pickerResult.append(newImage as? UIImage)
//                        }
//                    }
//                } else {
//                    print("Loaded Assest is not a Image")
//                }
//            }
//
//            parent.isPresented = false // Set isPresented to false because picking has finished.
//            parent.activeSheet = nil
//        }
//    }
//}
