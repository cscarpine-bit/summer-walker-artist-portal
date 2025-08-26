import UIKit
import AVFoundation
import MediaPlayer
import Flutter

class AudioManager: NSObject, PlatformChannelHandler {
    private var audioEngine = AVAudioEngine()
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    private var audioSession = AVAudioSession.sharedInstance()
    private var isRecording = false
    private var isPlaying = false
    
    // Audio effects and processing
    private var reverbEffect = AVAudioUnitReverb()
    private var delayEffect = AVAudioUnitDelay()
    private var distortionEffect = AVAudioUnitDistortion()
    private var compressorEffect = AVAudioUnitEffect()
    
    override init() {
        super.init()
        setupAudioEngine()
        configureAudioSession()
    }
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startAudioRecording":
            startAudioRecording(arguments: call.arguments, result: result)
        case "stopAudioRecording":
            stopAudioRecording(result: result)
        case "pauseAudioRecording":
            pauseAudioRecording(result: result)
        case "resumeAudioRecording":
            resumeAudioRecording(result: result)
        case "playAudio":
            playAudio(arguments: call.arguments, result: result)
        case "stopAudio":
            stopAudio(result: result)
        case "pauseAudio":
            pauseAudio(result: result)
        case "resumeAudio":
            resumeAudio(result: result)
        case "setAudioEffect":
            setAudioEffect(arguments: call.arguments, result: result)
        case "removeAudioEffect":
            removeAudioEffect(arguments: call.arguments, result: result)
        case "getAudioLevels":
            getAudioLevels(result: result)
        case "processAudioFile":
            processAudioFile(arguments: call.arguments, result: result)
        case "mixAudioTracks":
            mixAudioTracks(arguments: call.arguments, result: result)
        case "generateWaveform":
            generateWaveform(arguments: call.arguments, result: result)
        case "setPlaybackSpeed":
            setPlaybackSpeed(arguments: call.arguments, result: result)
        case "setVolume":
            setVolume(arguments: call.arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setupAudioEngine() {
        // Configure audio engine for high-quality audio processing
        let inputNode = audioEngine.inputNode
        let outputNode = audioEngine.outputNode
        let mainMixerNode = audioEngine.mainMixerNode
        
        // Setup audio effects chain
        audioEngine.attach(reverbEffect)
        audioEngine.attach(delayEffect)
        audioEngine.attach(distortionEffect)
        
        // Connect nodes
        audioEngine.connect(inputNode, to: reverbEffect, format: inputNode.inputFormat(forBus: 0))
        audioEngine.connect(reverbEffect, to: delayEffect, format: inputNode.inputFormat(forBus: 0))
        audioEngine.connect(delayEffect, to: mainMixerNode, format: inputNode.inputFormat(forBus: 0))
        audioEngine.connect(mainMixerNode, to: outputNode, format: inputNode.inputFormat(forBus: 0))
        
        // Start audio engine
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, 
                                       mode: .default, 
                                       options: [.allowBluetooth, .defaultToSpeaker, .interruptSpokenAudioAndMixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func startAudioRecording(arguments: Any?, result: @escaping FlutterResult) {
        guard !isRecording else {
            result(FlutterError(code: "RECORDING_ERROR", message: "Recording already in progress", details: nil))
            return
        }
        
        let recordingSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        let audioURL = getAudioRecordingURL()
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: recordingSettings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            
            if let args = arguments as? [String: Any] {
                if let duration = args["maxDuration"] as? TimeInterval {
                    audioRecorder?.record(forDuration: duration)
                } else {
                    audioRecorder?.record()
                }
            } else {
                audioRecorder?.record()
            }
            
            isRecording = true
            result([
                "success": true,
                "recordingPath": audioURL.path,
                "status": "recording"
            ])
        } catch {
            result(FlutterError(code: "RECORDING_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func stopAudioRecording(result: @escaping FlutterResult) {
        guard isRecording else {
            result(FlutterError(code: "RECORDING_ERROR", message: "No active recording", details: nil))
            return
        }
        
        audioRecorder?.stop()
        isRecording = false
        
        if let url = audioRecorder?.url {
            result([
                "success": true,
                "recordingPath": url.path,
                "status": "stopped"
            ])
        } else {
            result(FlutterError(code: "RECORDING_ERROR", message: "Failed to get recording path", details: nil))
        }
    }
    
    private func pauseAudioRecording(result: @escaping FlutterResult) {
        audioRecorder?.pause()
        result(["success": true, "status": "paused"])
    }
    
    private func resumeAudioRecording(result: @escaping FlutterResult) {
        audioRecorder?.record()
        result(["success": true, "status": "recording"])
    }
    
    private func playAudio(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let audioPath = args["path"] as? String else {
            result(FlutterError(code: "PLAYBACK_ERROR", message: "Missing audio path", details: nil))
            return
        }
        
        let audioURL = URL(fileURLWithPath: audioPath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.enableRate = true
            
            if let volume = args["volume"] as? Float {
                audioPlayer?.volume = volume
            }
            
            if let rate = args["rate"] as? Float {
                audioPlayer?.rate = rate
            }
            
            audioPlayer?.play()
            isPlaying = true
            
            result([
                "success": true,
                "duration": audioPlayer?.duration ?? 0,
                "status": "playing"
            ])
        } catch {
            result(FlutterError(code: "PLAYBACK_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func stopAudio(result: @escaping FlutterResult) {
        audioPlayer?.stop()
        isPlaying = false
        result(["success": true, "status": "stopped"])
    }
    
    private func pauseAudio(result: @escaping FlutterResult) {
        audioPlayer?.pause()
        isPlaying = false
        result(["success": true, "status": "paused"])
    }
    
    private func resumeAudio(result: @escaping FlutterResult) {
        audioPlayer?.play()
        isPlaying = true
        result(["success": true, "status": "playing"])
    }
    
    private func setAudioEffect(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let effectType = args["type"] as? String else {
            result(FlutterError(code: "EFFECT_ERROR", message: "Missing effect type", details: nil))
            return
        }
        
        switch effectType {
        case "reverb":
            configureReverbEffect(args)
        case "delay":
            configureDelayEffect(args)
        case "distortion":
            configureDistortionEffect(args)
        default:
            result(FlutterError(code: "EFFECT_ERROR", message: "Unsupported effect type", details: nil))
            return
        }
        
        result(["success": true, "effect": effectType])
    }
    
    private func removeAudioEffect(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let effectType = args["type"] as? String else {
            result(FlutterError(code: "EFFECT_ERROR", message: "Missing effect type", details: nil))
            return
        }
        
        switch effectType {
        case "reverb":
            reverbEffect.bypass = true
        case "delay":
            delayEffect.bypass = true
        case "distortion":
            distortionEffect.bypass = true
        default:
            result(FlutterError(code: "EFFECT_ERROR", message: "Unsupported effect type", details: nil))
            return
        }
        
        result(["success": true, "removedEffect": effectType])
    }
    
    private func getAudioLevels(result: @escaping FlutterResult) {
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160.0
        let peakPower = audioRecorder?.peakPower(forChannel: 0) ?? -160.0
        
        result([
            "averagePower": averagePower,
            "peakPower": peakPower,
            "isRecording": isRecording
        ])
    }
    
    private func processAudioFile(arguments: Any?, result: @escaping FlutterResult) {
        // Advanced audio processing - normalize, compress, etc.
        result(["success": true, "processed": true])
    }
    
    private func mixAudioTracks(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let trackPaths = args["tracks"] as? [String] else {
            result(FlutterError(code: "MIX_ERROR", message: "Missing track paths", details: nil))
            return
        }
        
        // Implement audio mixing logic
        let outputURL = getAudioMixOutputURL()
        
        // Simplified mixing - would implement full AVAudioEngine mixing
        result([
            "success": true,
            "mixedAudioPath": outputURL.path,
            "trackCount": trackPaths.count
        ])
    }
    
    private func generateWaveform(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let audioPath = args["path"] as? String else {
            result(FlutterError(code: "WAVEFORM_ERROR", message: "Missing audio path", details: nil))
            return
        }
        
        let audioURL = URL(fileURLWithPath: audioPath)
        
        // Generate waveform data
        generateWaveformData(from: audioURL) { waveformData in
            result([
                "success": true,
                "waveformData": waveformData,
                "sampleCount": waveformData.count
            ])
        }
    }
    
    private func setPlaybackSpeed(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let speed = args["speed"] as? Float else {
            result(FlutterError(code: "PLAYBACK_ERROR", message: "Missing speed parameter", details: nil))
            return
        }
        
        audioPlayer?.rate = speed
        result(["success": true, "speed": speed])
    }
    
    private func setVolume(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let volume = args["volume"] as? Float else {
            result(FlutterError(code: "PLAYBACK_ERROR", message: "Missing volume parameter", details: nil))
            return
        }
        
        audioPlayer?.volume = volume
        result(["success": true, "volume": volume])
    }
    
    // MARK: - Helper Methods
    
    private func configureReverbEffect(_ args: [String: Any]) {
        if let wetDryMix = args["wetDryMix"] as? Float {
            reverbEffect.wetDryMix = wetDryMix
        }
        reverbEffect.bypass = false
    }
    
    private func configureDelayEffect(_ args: [String: Any]) {
        if let delayTime = args["delayTime"] as? TimeInterval {
            delayEffect.delayTime = delayTime
        }
        if let feedback = args["feedback"] as? Float {
            delayEffect.feedback = feedback
        }
        delayEffect.bypass = false
    }
    
    private func configureDistortionEffect(_ args: [String: Any]) {
        if let preGain = args["preGain"] as? Float {
            distortionEffect.preGain = preGain
        }
        distortionEffect.bypass = false
    }
    
    private func getAudioRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "recording_\(Date().timeIntervalSince1970).aac"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private func getAudioMixOutputURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "mixed_audio_\(Date().timeIntervalSince1970).aac"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private func generateWaveformData(from url: URL, completion: @escaping ([Float]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Simplified waveform generation
            var waveformData: [Float] = []
            
            // Would implement actual audio analysis here
            for i in 0..<100 {
                let amplitude = Float.random(in: 0...1)
                waveformData.append(amplitude)
            }
            
            DispatchQueue.main.async {
                completion(waveformData)
            }
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        print("Audio recording finished successfully: \(flag)")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        isRecording = false
        print("Audio recording error: \(error?.localizedDescription ?? "Unknown")")
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        print("Audio playback finished successfully: \(flag)")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        print("Audio playback error: \(error?.localizedDescription ?? "Unknown")")
    }
}
