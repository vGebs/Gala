//
//  CameraViewModel.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-06-02.
//

import SwiftUI
import AVFoundation
import MediaPlayer

// Camera Model...
//------------------------------------------------------------------------------------------------------------------\
//Camera Model ------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------/
//public class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate{
//        
//    //Used to notify UI that frontFlash is active (i.e. picture is being taken)
//    @Published public var frontFlashActive = false
//
//    //Used to enable flash for next picture
//    @Published public var flashEnabled = true
//
//    //Used to notify the takepic-volume-button when the camera is on screen
//    @Published public var onCameraScreen = true
//
//    //Current camera in use [(front of rear) used for front flash in view]
//    @Published public var currentCamera = CameraSelection.front
//
//    //Bool to specify whether a pic was taken
//    @Published public var picTaken = false
//
//    //Bool to specify whether or not a pic was saved
//    @Published public var picSaved = false
//
//    //Pic Data
//    @Published public var image: UIImage?
//
//    public init(volumeCameraButton: Bool){
//        volumeCameraButtonOn = volumeCameraButton
//    }
//
//    //Core Functionality
//    public func makeUIView(_ viewBounds: UIView) -> UIView { makeUIView_(viewBounds) } //Try to move this to init
//    public func updateUIView() { updateUIView_() }
//    public func capturePhoto(){ prepareToTakePic_() }
//    public func retakePic(){ retakePic_() }
//    public func savePic(){ savePic_() }
//    public func toggleCamera(){ toggleCamera_() }
//
//
//    //View preview for the UIViewRepresentable
//    fileprivate var preview: AVCaptureVideoPreviewLayer!
//
//    //Used to Setup an AV Session
//    fileprivate var session = AVCaptureSession()
//
//    //Used to notify the preview that the user has denied access to the camera
//    fileprivate var alert = false
//
//    //Used to turn the takepic-volume-button on
//    private var volumeCameraButtonOn = false
//
//    //Video Setup
//    private var videoDevice: AVCaptureDevice?
//    private var videoDeviceInput: AVCaptureDeviceInput!
//
//    //Used for reading pic data
//    private var output = AVCapturePhotoOutput()
//
//    private var setupResult = SessionSetupResult.success
//
//    //Used to reset the volume after the user took pic w the volume button
//    private var audioLevel : Float = 0.0
//
//    deinit {
//        session.stopRunning()
//        print("Deinit Camera ViewModel: CameraViewModel.swift")
//    }
//}
//
////------------------------------------------------------------------------------------------------------------------\
////Setting view for preview ------------------------------------------------------------------------------------------
////------------------------------------------------------------------------------------------------------------------/
//extension CameraViewModel{
//    private func makeUIView_(_ viewBounds: UIView) -> UIView{
//        Check()
//        if !alert {
//            preview = AVCaptureVideoPreviewLayer(session: session)
//            preview.frame = viewBounds.frame
//
//            // Your Own Properties...
//            preview.videoGravity = .resizeAspectFill
//            preview.cornerRadius = 20
//            preview.masksToBounds = true
//            viewBounds.layer.addSublayer(preview)
//
//            listenVolumeButton()
//
//            // starting session
//            session.startRunning()
//        }
//
//        return viewBounds
//    }
//
//    private func updateUIView_() {
//        let brightness = CGFloat(0.35)
//
//        //Turns screen brightness all the way up to take front flash pic
//        if frontFlashActive {
//            UIScreen.main.brightness = CGFloat(1.0)
//        } else {
//            UIScreen.main.brightness = brightness
//        }
//    }
//}
//
//
//
////------------------------------------------------------------------------------------------------------------------\
////Core functionality-------------------------------------------------------------------------------------------------
////------------------------------------------------------------------------------------------------------------------/
//extension CameraViewModel{
//
//    private func prepareToTakePic_(){
//        guard let device = videoDevice else {
//            return
//        }
//
//        if device.hasFlash && flashEnabled == true && currentCamera == .rear {
//            picTaken.toggle()
//
//            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1) {
//                self.takePic_()
//            }
//
//            toggleFlash()
//
//        } else if flashEnabled == true && currentCamera == .front{
//            frontFlashActive = true
//            picTaken.toggle()
//
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//                self.frontFlashActive = false
//            }
//
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//                self.takePic_()
//            }
//
//        } else {
//            picTaken.toggle()
//            takePic_()
//        }
//
//        picSaved = false
//    }
//
//    private func takePic_(){
//        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
//
//        DispatchQueue.global(qos: .background).async {
//            self.session.stopRunning()
//        }
//    }
//
//    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//
//        if error != nil{
//            return
//        }
//
//        print("pic taken...")
//
//        //Flip image to save
//        if currentCamera == .front {
//            if let data = photo.fileDataRepresentation(){
//                let image = UIImage(data: data)!
//                let ciImage: CIImage = CIImage(cgImage: image.cgImage!).oriented(forExifOrientation: 6)
//                let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
//                self.image = UIImage.convert(from: flippedImage)
//            }
//        } else {
//            if let data = photo.fileDataRepresentation(){
//                self.image = UIImage(data: data)!
//            }
//        }
//    }
//
//    private func retakePic_(){
//        picSaved = false
//
//        DispatchQueue.global(qos: .background).async {
//
//            self.session.startRunning()
//
//            DispatchQueue.main.async {
//                self.picTaken.toggle()
//                //clearing ...
//                self.image = nil
//            }
//        }
//    }
//
//    private func savePic_(){
//        if let image = self.image{
//
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//
//            print("saved Successfully....")
//            picSaved = true
//        }
//    }
//
//    public enum CameraSelection: String {
//
//        /// Camera on the back of the device
//        case rear = "rear"
//
//        /// Camera on the front of the device
//        case front = "front"
//    }
//
//    private func toggleCamera_() {
//        guard session.isRunning == true else {
//            return
//        }
//
//        switch currentCamera {
//        case .front:
//            currentCamera = .rear
//        case .rear:
//            currentCamera = .front
//        }
//
//        session.stopRunning()
//
//        DispatchQueue.main.async {
//
//            // remove and re-add inputs and outputs
//
//            for input in self.session.inputs {
//                self.session.removeInput(input)
//            }
//
//            self.setUp()
//
//            self.session.startRunning()
//        }
//    }
//}
//
//
//
////------------------------------------------------------------------------------------------------------------------\
////Camera Init -------------------------------------------------------------------------------------------------------
////------------------------------------------------------------------------------------------------------------------/
//extension CameraViewModel {
//    private enum SessionSetupResult {
//        case success
//        case notAuthorized
//        case configurationFailed
//    }
//
//    fileprivate func Check(){
//
//        // first checking cameras got permission...
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            setUp()
//            return
//            // Setting Up Session
//        case .notDetermined:
//            // retesting for permission
//            AVCaptureDevice.requestAccess(for: .video) { status in
//                if status{
//                    self.setUp()
//                }
//            }
//        case .denied:
//            self.alert.toggle()
//            return
//
//        default:
//            return
//        }
//    }
//
//    func setUp(){
//        // setting up camera
//        addInputs()
//        addOutputs()
//    }
//
//    fileprivate func addInputs(){
//        session.beginConfiguration()
//        configureVideoPreset()
//        addVideoInput()
//        addAudioInput()
//        session.commitConfiguration()
//    }
//
//    private func configureVideoPreset() {
//
//        //Sets the video quality to high (other options available)
//        session.sessionPreset = AVCaptureSession.Preset(rawValue: AVCaptureSession.Preset.high.rawValue)
//
//
//
//        // Commented code below can be used to specify the video quality. For my purposes, I will only be using high. For more info, please check out SwiftyCam by Awalz on Github
//
////        if currentCamera == .front {
////            session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: .high))
////        } else {
////            if session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: videoQuality))) {
////                session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: videoQuality))
////            } else {
////                session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: .high))
////            }
////        }
//
//    }
//
//    private func addVideoInput() {
//        switch currentCamera {
//        case .front:
//            videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
////            SwiftyCamViewController.deviceWithMediaType(AVMediaType.video.rawValue, preferringPosition: .front)
//
//        case .rear:
//            videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
////                SwiftyCamViewController.deviceWithMediaType(AVMediaType.video.rawValue, preferringPosition: .back)
//        }
//
//        if let device = videoDevice {
//            do {
//                try device.lockForConfiguration()
//                if device.isFocusModeSupported(.continuousAutoFocus) {
//                    device.focusMode = .continuousAutoFocus
//                    if device.isSmoothAutoFocusSupported {
//                        device.isSmoothAutoFocusEnabled = true
//                    }
//                }
//
//                if device.isExposureModeSupported(.continuousAutoExposure) {
//                    device.exposureMode = .continuousAutoExposure
//                }
//
//                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
//                    device.whiteBalanceMode = .continuousAutoWhiteBalance
//                }
//
//                if device.isLowLightBoostSupported {
//                    device.automaticallyEnablesLowLightBoostWhenAvailable = true
//                }
//
//                device.unlockForConfiguration()
//            } catch {
//                print("[SwiftyCam]: Error locking configuration")
//            }
//        }
//
//        do {
//            if let videoDevice = videoDevice {
//                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
//                for outputs in session.outputs{ session.removeOutput(outputs) }
//
//                if session.canAddInput(videoDeviceInput) {
//                    session.addInput(videoDeviceInput)
//                    self.videoDeviceInput = videoDeviceInput
//                } else {
//                    print("[SwiftyCam]: Could not add video device input to the session")
//                    print(session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: AVCaptureSession.Preset.high.rawValue)))
//                    setupResult = .configurationFailed
//                    session.commitConfiguration()
//                    return
//                }
//            }
//
//        } catch {
//            print("[SwiftyCam]: Could not create video device input: \(error)")
//            setupResult = .configurationFailed
//            return
//        }
//    }
//
//    /// Add Audio Inputs
//    private func addAudioInput() {
//        do {
//            if let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio){
//                let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
//                if session.canAddInput(audioDeviceInput) {
//                    session.addInput(audioDeviceInput)
//                } else {
//                    print("[SwiftyCam]: Could not add audio device input to the session")
//                }
//
//            } else {
//                print("[SwiftyCam]: Could not find an audio device")
//            }
//
//        } catch {
//            print("[SwiftyCam]: Could not create audio device input: \(error)")
//        }
//    }
//
//    private func addOutputs(){
//        if self.session.canAddOutput(self.output){
//            self.session.addOutput(self.output)
//        }
//    }
//}
//
//
//
////------------------------------------------------------------------------------------------------------------------\
////Flash -------------------------------------------------------------------------------------------------------------
////------------------------------------------------------------------------------------------------------------------/
//extension CameraViewModel {
//
//    //Currently not in use
//    public enum FlashMode{
//        //Return the equivalent AVCaptureDevice.FlashMode
//        var AVFlashMode: AVCaptureDevice.FlashMode {
//            switch self {
//                case .on:
//                    return .on
//                case .off:
//                    return .off
//                case .auto:
//                    return .auto
//            }
//        }
//        //Flash mode is set to auto
//        case auto
//
//        //Flash mode is set to on
//        case on
//
//        //Flash mode is set to off
//        case off
//    }
//
//    private func toggleFlash(){
//
//        let device = AVCaptureDevice.default(for: AVMediaType.video)
//        // Check if device has a flash
//        if (device?.hasTorch)! {
//            do {
//                try device?.lockForConfiguration()
//                if (device?.torchMode == AVCaptureDevice.TorchMode.on) {
//                    device?.torchMode = AVCaptureDevice.TorchMode.off
//                } else {
//                    do {
//                        try device?.setTorchModeOn(level: 1.0)
//                    } catch {
//                        print("[SwiftyCam]: \(error)")
//                    }
//                }
//                device?.unlockForConfiguration()
//            } catch {
//                print("[SwiftUICam]: \(error)")
//            }
//        }
//    }
//}
//
//
//
////------------------------------------------------------------------------------------------------------------------\
////Click the volume button to snap pic -------------------------------------------------------------------------------
////------------------------------------------------------------------------------------------------------------------/
//extension CameraViewModel {
//    fileprivate func listenVolumeButton(){
//
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setActive(true, options: [])
//                audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
//                audioLevel = audioSession.outputVolume
//        } catch {
//            print("Error")
//        }
//    }
//
//    //Function is called when the volume button is pressed
//    //Fix so that the volume is unaffected when pressing ->  currentAudioLevel = audioLevel, *CLICK* audioLevel = currentAudioLevel (or something like that)
//    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "outputVolume"{
////                   let audioSession = AVAudioSession.sharedInstance()
////                   if audioSession.outputVolume > audioLevel {
////                        print("Hello")
////                   }
////                   if audioSession.outputVolume < audioLevel {
////                        print("GoodBye")
////                   }
////                   audioLevel = audioSession.outputVolume
////                   print(audioSession.outputVolume)
//
//            if picTaken == false && onCameraScreen && volumeCameraButtonOn{ //&& onCameraScreen
//                capturePhoto()
//            }
//        }
//    }
//}

extension UIImage{
    static func convert(from ciImage: CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}














import AVFoundation
import Combine
import SwiftUI
import CoreLocation

class CameraViewModel: ObservableObject {
    
    @Published public var picSaved = false
    @Published public var flashEnabled = false
    @Published public var image: UIImage?

    public var camFlipEnabled: Bool
    public var recordActionEnabled: Bool
    public var cameraButtonEnabled: Bool
    public var captureModeControl: Bool
    public var livePhotoEnabled: Bool
    public var depthEnabled: Bool
    public var photoQualityPrioritization: Bool
    //public var photoData
    
    
    let locationManager = CLLocationManager()
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified)

    
    // MARK: Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    
    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var setupResult: SessionSetupResult = .success
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    // MARK: Capturing Photos
    
    private let photoOutput = AVCapturePhotoOutput()
    
    
    // MARK: Mode Enums
    
    private enum LivePhotoMode {
        case on
        case off
    }
    
    private enum DepthDataDeliveryMode {
        case on
        case off
    }
    
    private var livePhotoMode: LivePhotoMode = .off
    private var depthDataDeliveryMode: DepthDataDeliveryMode = .off
    private var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .balanced

    private var movieFileOutput: AVCaptureMovieFileOutput?
    
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
        
        /*
         Do not create an AVCaptureMovieFileOutput when setting up the session because
         Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
         */
        session.sessionPreset = .photo
        session.sessionPreset = AVCaptureSession.Preset(rawValue: AVCaptureSession.Preset.high.rawValue)

        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera, if available, otherwise default to a wide angle camera.
            if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // If the rear wide angle camera isn't available, default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If a rear dual wide camera is not available, default to the rear wide angle camera.
                defaultVideoDevice = backCameraDevice
            }
            else if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            }
            else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                // If a rear dual camera is not available, default to the rear dual wide camera.
                defaultVideoDevice = dualWideCameraDevice
            }
            
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
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
        
        // Add an audio input device.
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
        
        // Add the photo output.
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
            
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        
        sessionQueue.async {
            
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    
                }
            }
        }
    }
    
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
    
    // MARK: KVO and Notifications
        
    private var keyValueObservations = [NSKeyValueObservation]()
    
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
    
    fileprivate var preview: AVCaptureVideoPreviewLayer!
    
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
}

extension CameraViewModel {
    public func makeUIView(_ viewBounds: UIView) -> UIView{
        
        if self.setupResult != .notAuthorized {
            preview = AVCaptureVideoPreviewLayer(session: session)
            preview.frame = viewBounds.frame

            // Your Own Properties...
            preview.videoGravity = .resizeAspectFill
            preview.cornerRadius = 20
            preview.masksToBounds = true
            viewBounds.layer.addSublayer(preview)
            // starting session
            //session.startRunning()
        }
        
        return viewBounds
    }
    
    public func updateUIView() {
        //let brightness = CGFloat(0.35)
        
        //Turns screen brightness all the way up to take front flash pic
        //        if frontFlashActive {
        //            UIScreen.main.brightness = CGFloat(1.0)
        //        } else {
        //            UIScreen.main.brightness = brightness
        //        }
    }
}

extension CameraViewModel {
    
    func savePic(){
        if let image = self.image{
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            print("saved Successfully....")
            picSaved = true
        }
    }
    
    func capturePhoto() {
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
                    let ciImage: CIImage = CIImage(cgImage: image.cgImage!).oriented(forExifOrientation: 6)
                    let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
                    self.image = UIImage.convert(from: flippedImage)

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
            photoCaptureProcessor.location = self.locationManager.location
            
            // The photo output holds a weak reference to the photo capture delegate and stores it in an array to maintain a strong reference.
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        
        }
    }
    
    public func retakePic() {
        self.image = nil
        self.picSaved = false
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        
        var uniqueDevicePositions = [AVCaptureDevice.Position]()
        
        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        
        return uniqueDevicePositions.count
    }
}

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
    var location: CLLocation?

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
