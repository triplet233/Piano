import SwiftUI
import AVFoundation

final class AudioManager {

    private var audioEngine = AVAudioEngine()
    
    let sampler = Sampler()
    let metronome = Metronome()
    
    init() {
        
        startAudioSession()
        
        setupAudioComponents()
        
        if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
            startAudioEngine()
            loadInstrument()
        }
    }
    
    func startAudioSession() {
#if !os(macOS)
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session:", error)
        }
#endif
    }
    
    
    func startAudioEngine() {
        if !audioEngine.isRunning {
            do {
                if audioEngine.outputNode.numberOfOutputs > 0 {
                    try audioEngine.start()
                } else {
                    print("AudioEngine has no output node connected yet.")
                }
            } catch {
                print("Failed to restart audio engine: \(error)")
            }
        }
    }
    
    private func setupAudioComponents() {
        guard !audioEngine.isRunning else { return }

        audioEngine.attach(metronome.sampler)
        audioEngine.connect(metronome.sampler, to: audioEngine.mainMixerNode, format: nil)
        
        audioEngine.attach(sampler.sampler)
        audioEngine.connect(sampler.sampler, to: audioEngine.mainMixerNode, format: nil)

    }
    
    
    func loadInstrument() {
        
        sampler.loadInstrument(.init(rawValue: UserDefaults.standard.string(forKey: "instrument") ?? "grand") ?? .grand)
    }
}
