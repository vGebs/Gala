//
//  VideoCaptureProcessor.swift
//  Gala
//
//  Created by Vaughn on 2021-10-22.
//

import AVFoundation

class VideoCaptureProcessor: NSObject {
    private(set) var uid: String
    private let completionHandler: (URL, Error?) -> Void
    var outputFileURL: URL?
    
    init(uid: String, completionHandler: @escaping (URL, Error?) -> Void){
        self.uid = uid
        self.completionHandler = completionHandler
    }
}

extension VideoCaptureProcessor: AVCaptureFileOutputRecordingDelegate {
    
    /// - Tag: DidStartRecording
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Enable the Record button to let the user stop recording.
        print("VideoCaptureProcessor: Did start recording")
    }
    
    /// - Tag: DidFinishRecording
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        // Note: Because we use a unique file path for each recording, a new recording won't overwrite a recording mid-save.
        
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
    
//            if let currentBackgroundRecordingID = backgroundRecordingID {
//                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
//
//                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
//                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
//                }
//            }
        }
        
        print("VideoCaptureProcessor: Did finish recording")
        
        if let error = error {
            print("VideoCaptureProcessor-ERROR: Movie file finishing error -> \(String(describing: error))")
            cleanup()
            return completionHandler(outputFileURL, error)
        } else {
            cleanup()
            return completionHandler(outputFileURL, error)
        }
    }
}
