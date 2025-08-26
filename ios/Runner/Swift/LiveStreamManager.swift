import UIKit
import AVFoundation
import ReplayKit
import Flutter

class LiveStreamManager: NSObject, PlatformChannelHandler {
    private var isStreaming = false
    private var streamSession: AVCaptureSession?
    private var rtmpSession: RTMPSession?
    private var screenRecorder = RPScreenRecorder.shared()
    
    override init() {
        super.init()
        setupLiveStream()
    }
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLiveStream":
            startLiveStream(arguments: call.arguments, result: result)
        case "stopLiveStream":
            stopLiveStream(result: result)
        case "pauseLiveStream":
            pauseLiveStream(result: result)
        case "resumeLiveStream":
            resumeLiveStream(result: result)
        case "getStreamStats":
            getStreamStats(result: result)
        case "updateStreamSettings":
            updateStreamSettings(arguments: call.arguments, result: result)
        case "startScreenShare":
            startScreenShare(result: result)
        case "stopScreenShare":
            stopScreenShare(result: result)
        case "switchAudioInput":
            switchAudioInput(arguments: call.arguments, result: result)
        case "setVideoQuality":
            setVideoQuality(arguments: call.arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setupLiveStream() {
        streamSession = AVCaptureSession()
        streamSession?.sessionPreset = .high
        
        guard let streamSession = streamSession else { return }
        
        // Setup video input for streaming
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Failed to setup video input for streaming")
            return
        }
        
        if streamSession.canAddInput(videoInput) {
            streamSession.addInput(videoInput)
        }
        
        // Setup audio input for streaming
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            print("Failed to setup audio input for streaming")
            return
        }
        
        if streamSession.canAddInput(audioInput) {
            streamSession.addInput(audioInput)
        }
        
        // Configure audio session for live streaming
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, 
                                       mode: .videoChat, 
                                       options: [.allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func startLiveStream(arguments: Any?, result: @escaping FlutterResult) {
        guard !isStreaming else {
            result(FlutterError(code: "STREAM_ERROR", message: "Stream already in progress", details: nil))
            return
        }
        
        guard let args = arguments as? [String: Any],
              let streamUrl = args["streamUrl"] as? String,
              let streamKey = args["streamKey"] as? String else {
            result(FlutterError(code: "INVALID_PARAMS", message: "Missing stream URL or key", details: nil))
            return
        }
        
        // Initialize RTMP session
        rtmpSession = RTMPSession(url: streamUrl, key: streamKey)
        
        // Configure stream quality
        if let quality = args["quality"] as? String {
            configureStreamQuality(quality: quality)
        }
        
        // Start capture session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.streamSession?.startRunning()
            self?.isStreaming = true
            
            // Start RTMP stream
            self?.rtmpSession?.start { success, error in
                DispatchQueue.main.async {
                    if success {
                        result([
                            "success": true,
                            "streamId": self?.generateStreamId() ?? "",
                            "status": "live"
                        ])
                    } else {
                        self?.isStreaming = false
                        result(FlutterError(code: "STREAM_ERROR", 
                                          message: error?.localizedDescription ?? "Failed to start stream", 
                                          details: nil))
                    }
                }
            }
        }
    }
    
    private func stopLiveStream(result: @escaping FlutterResult) {
        guard isStreaming else {
            result(FlutterError(code: "STREAM_ERROR", message: "No active stream", details: nil))
            return
        }
        
        streamSession?.stopRunning()
        rtmpSession?.stop()
        isStreaming = false
        
        result([
            "success": true,
            "status": "stopped"
        ])
    }
    
    private func pauseLiveStream(result: @escaping FlutterResult) {
        // Pause stream by muting audio/video
        rtmpSession?.pause()
        result(["success": true, "status": "paused"])
    }
    
    private func resumeLiveStream(result: @escaping FlutterResult) {
        // Resume stream
        rtmpSession?.resume()
        result(["success": true, "status": "live"])
    }
    
    private func getStreamStats(result: @escaping FlutterResult) {
        let stats = [
            "isLive": isStreaming,
            "viewerCount": rtmpSession?.viewerCount ?? 0,
            "bitrate": rtmpSession?.currentBitrate ?? 0,
            "fps": rtmpSession?.currentFPS ?? 0,
            "resolution": rtmpSession?.currentResolution ?? "720p",
            "duration": rtmpSession?.streamDuration ?? 0
        ] as [String: Any]
        
        result(stats)
    }
    
    private func updateStreamSettings(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_PARAMS", message: "Invalid parameters", details: nil))
            return
        }
        
        if let bitrate = args["bitrate"] as? Int {
            rtmpSession?.setBitrate(bitrate)
        }
        
        if let fps = args["fps"] as? Int {
            rtmpSession?.setFPS(fps)
        }
        
        result(["success": true])
    }
    
    private func startScreenShare(result: @escaping FlutterResult) {
        guard screenRecorder.isAvailable else {
            result(FlutterError(code: "SCREEN_SHARE_ERROR", message: "Screen recording not available", details: nil))
            return
        }
        
        screenRecorder.startCapture { [weak self] (sampleBuffer, bufferType, error) in
            if let error = error {
                print("Screen capture error: \(error)")
                return
            }
            
            // Process screen capture buffer for streaming
            self?.processScreenBuffer(sampleBuffer, bufferType: bufferType)
        } completionHandler: { error in
            if let error = error {
                result(FlutterError(code: "SCREEN_SHARE_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(["success": true, "status": "screen_sharing"])
            }
        }
    }
    
    private func stopScreenShare(result: @escaping FlutterResult) {
        screenRecorder.stopCapture { error in
            if let error = error {
                result(FlutterError(code: "SCREEN_SHARE_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(["success": true, "status": "stopped"])
            }
        }
    }
    
    private func switchAudioInput(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let inputType = args["inputType"] as? String else {
            result(FlutterError(code: "INVALID_PARAMS", message: "Missing input type", details: nil))
            return
        }
        
        // Switch between microphone, bluetooth, etc.
        switch inputType {
        case "microphone":
            configureAudioInput(.builtInMicrophone)
        case "bluetooth":
            configureAudioInput(.bluetoothHFP)
        case "wired":
            configureAudioInput(.wiredHeadset)
        default:
            result(FlutterError(code: "INVALID_PARAMS", message: "Unsupported input type", details: nil))
            return
        }
        
        result(["success": true, "inputType": inputType])
    }
    
    private func setVideoQuality(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let quality = args["quality"] as? String else {
            result(FlutterError(code: "INVALID_PARAMS", message: "Missing quality parameter", details: nil))
            return
        }
        
        configureStreamQuality(quality: quality)
        result(["success": true, "quality": quality])
    }
    
    private func configureStreamQuality(quality: String) {
        guard let streamSession = streamSession else { return }
        
        switch quality {
        case "high":
            streamSession.sessionPreset = .high
            rtmpSession?.setResolution(width: 1920, height: 1080)
            rtmpSession?.setBitrate(4000000) // 4 Mbps
        case "medium":
            streamSession.sessionPreset = .medium
            rtmpSession?.setResolution(width: 1280, height: 720)
            rtmpSession?.setBitrate(2000000) // 2 Mbps
        case "low":
            streamSession.sessionPreset = .low
            rtmpSession?.setResolution(width: 640, height: 480)
            rtmpSession?.setBitrate(1000000) // 1 Mbps
        default:
            streamSession.sessionPreset = .medium
        }
    }
    
    private func configureAudioInput(_ portType: AVAudioSession.Port) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            let availableInputs = audioSession.availableInputs
            let targetInput = availableInputs?.first { $0.portType == portType }
            
            if let input = targetInput {
                try audioSession.setPreferredInput(input)
            }
        } catch {
            print("Failed to configure audio input: \(error)")
        }
    }
    
    private func processScreenBuffer(_ sampleBuffer: CMSampleBuffer, bufferType: RPSampleBufferType) {
        // Process screen capture buffer and send to RTMP stream
        rtmpSession?.processScreenBuffer(sampleBuffer, bufferType: bufferType)
    }
    
    private func generateStreamId() -> String {
        return "stream_\(Date().timeIntervalSince1970)_\(UUID().uuidString.prefix(8))"
    }
}

// MARK: - RTMP Session (Simplified Implementation)
class RTMPSession {
    private let url: String
    private let key: String
    private(set) var isConnected = false
    private(set) var viewerCount = 0
    private(set) var currentBitrate = 0
    private(set) var currentFPS = 30
    private(set) var currentResolution = "720p"
    private(set) var streamDuration: TimeInterval = 0
    
    init(url: String, key: String) {
        self.url = url
        self.key = key
    }
    
    func start(completion: @escaping (Bool, Error?) -> Void) {
        // Simulate RTMP connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isConnected = true
            completion(true, nil)
        }
    }
    
    func stop() {
        isConnected = false
    }
    
    func pause() {
        // Pause implementation
    }
    
    func resume() {
        // Resume implementation
    }
    
    func setBitrate(_ bitrate: Int) {
        currentBitrate = bitrate
    }
    
    func setFPS(_ fps: Int) {
        currentFPS = fps
    }
    
    func setResolution(width: Int, height: Int) {
        currentResolution = "\(width)x\(height)"
    }
    
    func processScreenBuffer(_ sampleBuffer: CMSampleBuffer, bufferType: RPSampleBufferType) {
        // Process and encode buffer for streaming
    }
}
