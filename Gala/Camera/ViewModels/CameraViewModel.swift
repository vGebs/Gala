//
//  CameraViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-06-02.
//

import AVFoundation
import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    
    // MARK: - General Purpose Public variables
    
    @Published public var picSaved = false
    @Published public var flashEnabled = false
    @Published public var image: UIImage?

    
    //MARK: - Core Functionality
    
    //Call makeUIView inside of your UIViewRepresentable struct
    public func makeUIView(_ viewBounds: UIView) -> UIView { makeUIView_(viewBounds) }
    
    public func capturePhoto() { capturePhoto_() }
    public func retakePic(){ retakePic_() }
    public func savePic(){ savePic_() }
    public func toggleCamera(){ toggleCamera_() }
    
    //Tear down camera when camera is not in use
    public func tearDownCamera() { tearDownCamera_() }
    
    //Build camera once it is needed again
    public func buildCam() { buildCam_() }

    
    // MARK: - Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    //Setup result is .success by default
    private var setupResult: SessionSetupResult = .success
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    
    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "session queue")
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    
    // MARK: - Capturing Photos
    
    private let photoOutput = AVCapturePhotoOutput()
    private var photoOutputEnabled = false
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .balanced
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    fileprivate var preview: AVCaptureVideoPreviewLayer!

    
    // MARK: - KVO and Notifications
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    
    // MARK: - Current Camera
    
    private enum CurrentCamera {
        case front
        case back
    }
    private var currentCamera: CurrentCamera = .front
    
    
    // MARK: - Live Photo
    
    private enum LivePhotoMode {
        case on
        case off
    }
    private var livePhotoMode: LivePhotoMode = .off

    
    // MARK: - Photo Depth
    
    private enum DepthDataDeliveryMode {
        case on
        case off
    }
    private var depthDataDeliveryMode: DepthDataDeliveryMode = .off

    
    // MARK: - General Purpose Private Variables
    
    private var camFlipEnabled: Bool
    private var recordActionEnabled: Bool
    private var cameraButtonEnabled: Bool
    private var captureModeControl: Bool
    private var livePhotoEnabled: Bool
    private var depthEnabled: Bool
    private var photoQualityPrioritization: Bool
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified)
    
    
    // MARK: - Initializer
    init() {
        self.camFlipEnabled = false
        self.recordActionEnabled = false
        self.cameraButtonEnabled = false
        self.captureModeControl = false
        self.livePhotoEnabled = false
        self.depthEnabled = false
        self.photoQualityPrioritization = false
        
        /*
         Check the video authorization status. Video access is required and audio
         access is optional. If the user denies audio access, AVCam won't
         record audio during movie recording.
        */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        /*
         Setup the capture session.
         In general, it's not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Don't perform these tasks on the main queue because
         AVCaptureSession.startRunning() is a blocking call, which can
         take a long time. Dispatch session setup to the sessionQueue, so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    // Call this on the session queue.
    /// - Tag: ConfigureSession
    private func configureSession() {
        
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        // Add video input.
        self.addVideoInput()
        
        // Add an audio input device.
        self.addAudioInput()
        
        // Add the photo output.
        self.addPhotoOutput()
        
        session.commitConfiguration()
        
        self.checkSetupResult()
    }
}

//MARK: - Initializer helpers --------------------------------------------------------------------------------->
extension CameraViewModel {
    private func selectCamera() -> AVCaptureDevice? {
        var defaultVideoDevice: AVCaptureDevice?
        
        if self.currentCamera == .front {
            if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
        } else {
            if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            }
            else if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            }
            else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                defaultVideoDevice = dualWideCameraDevice
            }
        }
        
        return defaultVideoDevice
    }
    private func addVideoInput() {
        /*
         Do not create an AVCaptureMovieFileOutput when setting up the session because
         Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
         */
        session.sessionPreset = .photo
        session.sessionPreset = AVCaptureSession.Preset(rawValue: AVCaptureSession.Preset.high.rawValue)
        
        do {
            let defaultVideoDevice = self.selectCamera()
            
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                print(videoDeviceInput)
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
    }
    
    private func addAudioInput() {
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
    }
    
    private func addPhotoOutput() {
        if !photoOutputEnabled {
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
                photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
                photoOutput.isPortraitEffectsMatteDeliveryEnabled = photoOutput.isPortraitEffectsMatteDeliverySupported
                photoOutput.enabledSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes
                photoOutput.maxPhotoQualityPrioritization = .quality
                livePhotoMode = photoOutput.isLivePhotoCaptureSupported ? .on : .off
                depthDataDeliveryMode = photoOutput.isDepthDataDeliverySupported ? .on : .off
                photoQualityPrioritizationMode = .balanced
                
                photoOutputEnabled = true
            } else {
                print("Could not add photo output to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        }
    }
    
    private func checkSetupResult() {
        sessionQueue.async {
            
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    print("AVCam doesn't have permission to use the camera, please change privacy settings")
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    print("Alert message when something goes wrong during capture session configuration")
                }
            }
        }
    }
}

// MARK: - Core Functionality --------------------------------------------------------------------------------->

extension CameraViewModel {
    private func makeUIView_(_ viewBounds: UIView) -> UIView{
        
        if self.setupResult != .notAuthorized {
            preview = AVCaptureVideoPreviewLayer(session: session)
            preview.frame = viewBounds.frame

            // Your Own Properties...
            preview.videoGravity = .resizeAspectFill
            preview.cornerRadius = 20
            preview.masksToBounds = true
            viewBounds.layer.addSublayer(preview)
        }
        
        return viewBounds
    }
    
    private func capturePhoto_() {
        /*
         Retrieve the video preview layer's video orientation on the main queue before
         entering the session queue. Do this to ensure that UI elements are accessed on
         the main thread and session configuration is done on the session queue.
         */
        
        sessionQueue.async {
            
            var photoSettings = AVCapturePhotoSettings()
            
            // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                if self.flashEnabled {
                    photoSettings.flashMode = .on
                } else {
                    photoSettings.flashMode = .off
                }
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            // Live Photo capture is not supported in movie mode.
            if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported {
                let livePhotoMovieFileName = NSUUID().uuidString
                let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
                photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
            }
            
            photoSettings.isDepthDataDeliveryEnabled = (self.depthDataDeliveryMode == .on
                                                        && self.photoOutput.isDepthDataDeliveryEnabled)
            
            photoSettings.photoQualityPrioritization = self.photoQualityPrioritizationMode
            
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                // Flash the screen to signal that AVCam took a photo.
//                DispatchQueue.main.async {
//                    self.preview.opacity = 0
//                    UIView.animate(withDuration: 0.25) {
//                        self.preview.opacity = 1
//                    }
//                }
            }, completionHandler: { photoCaptureProcessor in
                
                if let data = photoCaptureProcessor.photoData {
                    let image = UIImage(data: data)!
                    
                    if self.currentCamera == .front {
                        let ciImage: CIImage = CIImage(cgImage: image.cgImage!).oriented(forExifOrientation: 6)
                        let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
                        self.image = UIImage.convert(from: flippedImage)
                    } else {
                        self.image = image
                    }

                    print("Got photo")
                } else {
                    print("CameraViewModel: Pic was not recieved from photoCaptureProcessor")
                }
                
                // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
            })
            
            // Specify the location the photo was taken
            //photoCaptureProcessor.location = self.locationManager.location
            
            // The photo output holds a weak reference to the photo capture delegate and stores it in an array to maintain a strong reference.
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        
        }
    }
    
    private func retakePic_() {
        self.image = nil
        self.picSaved = false
    }
    
    private func savePic_(){
        if let image = self.image{
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            print("saved Successfully....")
            picSaved = true
        }
    }
    
    private func toggleCamera_() {
        guard session.isRunning == true else {
            return
        }
        
        switch currentCamera {
        case .front:
            currentCamera = .back
        case .back:
            currentCamera = .front
        }
        
        sessionQueue.async {
            self.session.stopRunning()

            // remove and re-add inputs and outputs
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            
            self.removeObservers()
            self.configureSession()
            
            self.session.startRunning()
        }
    }
    
    private func tearDownCamera_() {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
    }
    
    private func buildCam_() {
        sessionQueue.async {
            // remove and re-add inputs and outputs
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            self.configureSession()
            
            self.session.startRunning()
        }
    }
}

// MARK: - KVO & Notifications --------------------------------------------------------------------------------->

extension CameraViewModel {
    /// - Tag: ObserveInterruption
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            let isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureEnabled
            let isDepthDeliveryDataEnabled = self.photoOutput.isDepthDataDeliveryEnabled
            
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.camFlipEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                self.recordActionEnabled = isSessionRunning && self.movieFileOutput != nil
                self.cameraButtonEnabled = isSessionRunning
                self.captureModeControl = isSessionRunning
                self.livePhotoEnabled = isSessionRunning && isLivePhotoCaptureEnabled
                self.depthEnabled = isSessionRunning && isDepthDeliveryDataEnabled
                
                self.photoQualityPrioritization = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        let systemPressureStateObservation = videoDeviceInput.observe(\.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
    }
    
    /// - Tag: HandleRuntimeError
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    /// - Tag: HandleSystemPressure
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        /*
         The frame rates used here are only for demonstration purposes.
         Your frame rate throttling may be different depending on your app's camera configuration.
         */
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if self.movieFileOutput == nil || self.movieFileOutput?.isRecording == false {
                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                    self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                    self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                    self.videoDeviceInput.device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        } else if pressureLevel == .shutdown {
            print("Session stopped running due to shutdown system pressure level.")
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
}

extension CameraViewModel {
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("CameraViewModel-Error: Could not lock device for configuration: \(error)")
            }
        }
    }
}
