import UIKit
import Flutter
import AVFoundation
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var cameraManager: CameraManager?
    private var liveStreamManager: LiveStreamManager?
    private var audioManager: AudioManager?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // Initialize native Swift managers
        setupNativeModules(controller: controller)
        
        // Request necessary permissions
        requestPermissions()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupNativeModules(controller: FlutterViewController) {
        // Enhanced Camera Channel
        let cameraChannel = FlutterMethodChannel(
            name: "summer_walker_app/camera",
            binaryMessenger: controller.binaryMessenger
        )
        cameraManager = CameraManager()
        cameraChannel.setMethodCallHandler(cameraManager?.handleMethodCall)
        
        // Live Stream Channel
        let streamChannel = FlutterMethodChannel(
            name: "summer_walker_app/live_stream",
            binaryMessenger: controller.binaryMessenger
        )
        liveStreamManager = LiveStreamManager()
        streamChannel.setMethodCallHandler(liveStreamManager?.handleMethodCall)
        
        // Audio Processing Channel
        let audioChannel = FlutterMethodChannel(
            name: "summer_walker_app/audio",
            binaryMessenger: controller.binaryMessenger
        )
        audioManager = AudioManager()
        audioChannel.setMethodCallHandler(audioManager?.handleMethodCall)
    }
    
    private func requestPermissions() {
        // Camera permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("Camera permission: \(granted)")
        }
        
        // Microphone permission
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            print("Microphone permission: \(granted)")
        }
        
        // Photo library permission
        PHPhotoLibrary.requestAuthorization { status in
            print("Photo library permission: \(status)")
        }
    }
}

// MARK: - Platform Channel Handler Protocol
protocol PlatformChannelHandler {
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult)
}
