import AVFoundation


class Metronome: @unchecked Sendable {
    let sampler = AVAudioUnitSampler()
    private var task: Task<Void, Never>?
    
    init() {
        setGain(UserDefaults.standard.float(forKey: "metronomeGain"))
        loadSound()
    }
    
    var isOn: Bool {
        task != nil
    }
    
    func setGain(_ gain: Float) {
        sampler.overallGain = gain
    }
    
    func startTask(tempo: Double) {
        stopTask()
        
        task = Task {
            for await _ in timerStream(interval: 60.0 / tempo) {
                playTick()
            }
        }
    }
    
    func startCountIn(tempo: Double, _ beats: Int) async {
        for await beat in timerStream(interval: 60.0 / tempo) {
            guard beat < beats else { break }
            self.playTick()
        }
    }
    
    func stopTask() {
        task?.cancel()
        task = nil
    }
    
    private func loadSound() {
        let buffer = Self.createMetronomeSound()
        let tempURL = Self.createTempSoundFile(from: buffer)
        do {
            try sampler.loadAudioFiles(at: [tempURL])
        } catch {
            print("Failed to load sound: \(error)")
        }
    }
    
    private func playTick() {
        sampler.startNote(60, withVelocity: 127, onChannel: 0)
    }
    
    static private func createMetronomeSound() -> AVAudioPCMBuffer {
        let sampleRate = 44100.0
        let duration = 0.1
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!, frameCapacity: frameCount)!
        
        buffer.frameLength = frameCount
        
        let samples = buffer.floatChannelData?[0]
        for i in 0..<Int(frameCount) {
            let time = Double(i) / sampleRate
            let frequency = 1000.0
            let decay = exp(-time * 50) // Faster decay for sharper click
            let amplitude = Float(decay)
            let phase = 2.0 * Double.pi * frequency * time
            let sineValue = sin(phase)
            samples?[i] = amplitude * Float(sineValue)
        }
        
        return buffer
    }
    
    static private func createTempSoundFile(from buffer: AVAudioPCMBuffer) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("metronome_temp.wav")
        
        do {
            let file = try AVAudioFile(forWriting: tempURL, settings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: buffer.format.sampleRate,
                AVNumberOfChannelsKey: buffer.format.channelCount,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false
            ])
            try file.write(from: buffer)
        } catch {
            print("Failed to create temp sound file: \(error)")
        }
        
        return tempURL
    }

}



