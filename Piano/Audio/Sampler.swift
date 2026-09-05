import Foundation
import AVFoundation

extension AVAudioUnitSampler {
    func loadInstrument(_ instrument: Instrument) {
        guard let url = instrument.url else { return }
        try? self.loadSoundBankInstrument(at: url, program: instrument.program, bankMSB: instrument.bank, bankLSB: 0x00)
    }
}

class Sampler {
    let sampler = AVAudioUnitSampler()
    
    init() {
        setGain(UserDefaults.standard.float(forKey: "keyboardVolume"))
    }
    
    func setGain(_ gain: Float) {
        sampler.overallGain = gain
    }
    
    func loadInstrument(_ instrument: Instrument) {
        sampler.loadInstrument(instrument)
    }
    
    func startNote(_ note: Int, withVelocity velocity: Int) {
        sampler.startNote(UInt8(note), withVelocity: UInt8(velocity), onChannel: 0)
    }
    
    func startNote(_ note: Int) {
        startNote(note, withVelocity: 105)
    }
    
    func stopNote(_ note: Int) {
        sampler.stopNote(UInt8(note), onChannel: 0)
    }
    
    func sustainPedalOn() {
        sampler.sendController(64, withValue: 127, onChannel: 0)
    }
    
    func sustainPedalOff() {
        sampler.sendController(64, withValue: 0, onChannel: 0)
    }
    
    func stopAllNotes() {
        sampler.sendController(123, withValue: 0, onChannel: 0)
    }
}
