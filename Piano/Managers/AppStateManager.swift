import Foundation

enum Constants {
    
    static let bpmRange = 60...150
}

class AppStateManager {

    var playModeKey: PitchClass
    var identifyMultipleChords: Bool
    
    init() {
        let defaultPlayModeKey = UserDefaults.standard.string(forKey: "playModeKey") ?? "C"
        playModeKey = PitchClass(rawValue: defaultPlayModeKey) ?? .C
        
        identifyMultipleChords = UserDefaults.standard.bool(forKey: "identifyMultipleChords")
    }
    
    func setPlayModeKey(_ content: String) {
        playModeKey = PitchClass(rawValue: content) ?? .C
    }
    
    func setIdentifyMultipleChords(_ value: Bool) {
        identifyMultipleChords = value
    }

}
