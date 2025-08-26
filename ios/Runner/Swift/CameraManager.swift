import UIKit
import AVFoundation
import Photos
import Flutter

class CameraManager: NSObject, PlatformChannelHandler {
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startCamera":
            startCamera(result: result)
        case "stopCamera":
            stopCamera(result: result)
        case "takePhoto":
            takePhoto(arguments: call.arguments, result: result)
        case "startVideoRecording":
            startVideoRecording(arguments: call.arguments, result: result)
        case "stopVideoRecording":
            stopVideoRecording(result: result)
        case "switchCamera":
            switchCamera(result: result)
        case "setFlashMode":
            setFlashMode(arguments: call.arguments, result: result)
        case "getAvailableResolutions":
            getAvailableResolutions(result: result)
        case "setResolution":
            setResolution(arguments: call.arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        guard let captureSession = captureSession else { return }
        
        // Setup video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Failed to setup video input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Setup audio input for video recording
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            print("Failed to setup audio input")
            return
        }
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        // Setup photo output
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // Setup video output
        videoOutput = AVCaptureMovieFileOutput()
        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }
    
    private func startCamera(result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            DispatchQueue.main.async {
                result(["success": true])
            }
        }
    }
    
    private func stopCamera(result: @escaping FlutterResult) {
        captureSession?.stopRunning()
        result(["success": true])
    }
    
    private func takePhoto(arguments: Any?, result: @escaping FlutterResult) {
        guard let photoOutput = photoOutput else {
            result(FlutterError(code: "CAMERA_ERROR", message: "Photo output not available", details: nil))
            return
        }
        
        let settings = AVCapturePhotoSettings()
        
        // Configure photo settings based on arguments
        if let args = arguments as? [String: Any] {
            if let quality = args["quality"] as? String {
                switch quality {
                case "high":
                    settings.photoQualityPrioritization = .quality
                case "balanced":
                    settings.photoQualityPrioritization = .balanced
                case "speed":
                    settings.photoQualityPrioritization = .speed
                default:
                    settings.photoQualityPrioritization = .balanced
                }
            }
            
            if let enableFlash = args["flash"] as? Bool {
                settings.flashMode = enableFlash ? .auto : .off
            }
        }
        
        let delegate = PhotoCaptureDelegate(result: result)
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    private func startVideoRecording(arguments: Any?, result: @escaping FlutterResult) {
        guard let videoOutput = videoOutput else {
            result(FlutterError(code: "CAMERA_ERROR", message: "Video output not available", details: nil))
            return
        }
        
        let outputURL = getVideoOutputURL()
        
        // Configure video recording settings
        if let args = arguments as? [String: Any] {
            if let maxDuration = args["maxDuration"] as? Double {
                videoOutput.maxRecordedDuration = CMTime(seconds: maxDuration, preferredTimescale: 600)
            }
        }
        
        let delegate = VideoRecordingDelegate(result: result)
        videoOutput.startRecording(to: outputURL, recordingDelegate: delegate)
    }
    
    private func stopVideoRecording(result: @escaping FlutterResult) {
        videoOutput?.stopRecording()
        result(["success": true])
    }
    
    private func switchCamera(result: @escaping FlutterResult) {
        // Implementation for switching between front and back camera
        result(["success": true])
    }
    
    private func setFlashMode(arguments: Any?, result: @escaping FlutterResult) {
        // Implementation for setting flash mode
        result(["success": true])
    }
    
    private func getAvailableResolutions(result: @escaping FlutterResult) {
        let resolutions = [
            ["width": 1920, "height": 1080, "name": "1080p"],
            ["width": 1280, "height": 720, "name": "720p"],
            ["width": 640, "height": 480, "name": "480p"]
        ]
        result(resolutions)
    }
    
    private func setResolution(arguments: Any?, result: @escaping FlutterResult) {
        // Implementation for setting camera resolution
        result(["success": true])
    }
    
    private func getVideoOutputURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "video_\(Date().timeIntervalSince1970).mp4"
        return documentsDirectory.appendingPathComponent(fileName)
    }
}

// MARK: - Photo Capture Delegate
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let result: FlutterResult
    
    init(result: @escaping FlutterResult) {
        self.result = result
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            result(FlutterError(code: "PHOTO_ERROR", message: error.localizedDescription, details: nil))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            result(FlutterError(code: "PHOTO_ERROR", message: "Failed to get image data", details: nil))
            return
        }
        
        // Save to photo library
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: imageData, options: nil)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.result(["success": true, "path": "photo_library"])
                } else {
                    self.result(FlutterError(code: "SAVE_ERROR", message: "Failed to save photo", details: nil))
                }
            }
        }
    }
}

// MARK: - Video Recording Delegate
class VideoRecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    private let result: FlutterResult
    
    init(result: @escaping FlutterResult) {
        self.result = result
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            result(FlutterError(code: "VIDEO_ERROR", message: error.localizedDescription, details: nil))
            return
        }
        
        // Save to photo library
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.result(["success": true, "path": outputFileURL.path])
                } else {
                    self.result(FlutterError(code: "SAVE_ERROR", message: "Failed to save video", details: nil))
                }
            }
        }
    }
}
