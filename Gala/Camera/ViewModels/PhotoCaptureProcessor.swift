//
//  PhotoCaptureProcessor.swift
//  Gala
//
//  Created by Vaughn on 2021-10-13.
//

import AVFoundation

class PhotoCaptureProcessor: NSObject {
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    
    private let willCapturePhotoAnimation: () -> Void
    
    //private let livePhotoCaptureHandler: (Bool) -> Void
    
    //lazy var context = CIContext()
    
    private let completionHandler: (PhotoCaptureProcessor) -> Void
    
    //private let photoProcessingHandler: (Bool) -> Void
    
    public var photoData: Data?
    
    private var livePhotoCompanionMovieURL: URL?
    
    private var semanticSegmentationMatteDataArray = [Data]()
    private var maxPhotoProcessingTime: CMTime?

    // Save the location of captured photos
    //var location: CLLocation?

    init(with requestedPhotoSettings: AVCapturePhotoSettings, //livePhotoCaptureHandler: @escaping (Bool) -> Void,
         willCapturePhotoAnimation: @escaping () -> Void,
         completionHandler: @escaping (PhotoCaptureProcessor) -> Void
         ) { //photoProcessingHandler: @escaping (Bool) -> Void
        
        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        //self.livePhotoCaptureHandler = livePhotoCaptureHandler
        self.completionHandler = completionHandler
        //self.photoProcessingHandler = photoProcessingHandler
    }
    
    public func getImageData() -> Data? {
        if let photoData = photoData {
            return photoData
        } else {
            return nil
        }
    }
    
    private func didFinish() {
//        if let livePhotoCompanionMoviePath = livePhotoCompanionMovieURL?.path {
//            if FileManager.default.fileExists(atPath: livePhotoCompanionMoviePath) {
//                do {
//                    try FileManager.default.removeItem(atPath: livePhotoCompanionMoviePath)
//                } catch {
//                    print("Could not remove file at url: \(livePhotoCompanionMoviePath)")
//                }
//            }
//        }
        
        completionHandler(self)
    }
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    /*
     This extension adopts all of the AVCapturePhotoCaptureDelegate protocol methods.
     */
    
    /// - Tag: WillBeginCapture
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
//        if resolvedSettings.livePhotoMovieDimensions.width > 0 && resolvedSettings.livePhotoMovieDimensions.height > 0 {
//            livePhotoCaptureHandler(true)
//        }
        maxPhotoProcessingTime = resolvedSettings.photoProcessingTimeRange.start + resolvedSettings.photoProcessingTimeRange.duration
    }
    
    /// - Tag: WillCapturePhoto
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhotoAnimation()
        
//        guard let maxPhotoProcessingTime = maxPhotoProcessingTime else {
//            return
//        }
//
//        // Show a spinner if processing time exceeds one second.
//        let oneSecond = CMTime(seconds: 1, preferredTimescale: 1)
//        if maxPhotoProcessingTime > oneSecond {
//            photoProcessingHandler(true)
//        }
    }
    
    /// - Tag: DidFinishProcessingPhoto
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //photoProcessingHandler(false)

        if let error = error {
            print("Error capturing photo: \(error)")
            return
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }
    
    /// - Tag: DidFinishRecordingLive
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        //livePhotoCaptureHandler(false)
    }
    
    /// - Tag: DidFinishProcessingLive
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if error != nil {
            print("Error processing Live Photo companion movie: \(String(describing: error))")
            return
        }
        livePhotoCompanionMovieURL = outputFileURL
    }
    
    /// - Tag: DidFinishCapture
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            didFinish()
            return
        }

        if let _ = photoData {
            didFinish()
            return
        } else {
            print("No photo data resource")
            didFinish()
            return
        }

//        PHPhotoLibrary.requestAuthorization { status in
//            if status == .authorized {
//                PHPhotoLibrary.shared().performChanges({
//                    let options = PHAssetResourceCreationOptions()
//                    let creationRequest = PHAssetCreationRequest.forAsset()
//                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
//                    creationRequest.addResource(with: .photo, data: photoData, options: options)
//
//                    // Specify the location the photo was taken
//                    creationRequest.location = self.location
//
//                    if let livePhotoCompanionMovieURL = self.livePhotoCompanionMovieURL {
//                        let livePhotoCompanionMovieFileOptions = PHAssetResourceCreationOptions()
//                        livePhotoCompanionMovieFileOptions.shouldMoveFile = true
//                        creationRequest.addResource(with: .pairedVideo,
//                                                    fileURL: livePhotoCompanionMovieURL,
//                                                    options: livePhotoCompanionMovieFileOptions)
//                    }
//                }, completionHandler: { _, error in
//                    if let error = error {
//                        print("Error occurred while saving photo to photo library: \(error)")
//                    }
//
//                    self.didFinish()
//                }
//                )
//            } else {
//                self.didFinish()
//            }
//        }
    }
}
