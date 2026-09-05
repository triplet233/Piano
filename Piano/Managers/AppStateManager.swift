import Foundation

enum Constants {
    static let ticksPerBeat = 12
    static let bpmRange = 60...150
}

class AppStateManager {

    var playModeKey: PitchClass
    var voicingBound: Int
    var humanize: Bool = false
    
    init() {
        let defaultPlayModeKey = UserDefaults.standard.string(forKey: "playModeKey") ?? "C"
        playModeKey = PitchClass(rawValue: defaultPlayModeKey) ?? .C
        
        let defaultVoicingBound = UserDefaults.standard.integer(forKey: "voicingLevel")
        voicingBound = voicingLevels[defaultVoicingBound]?.note.midiNote ?? Note(.G, 3).midiNote
        
        let defaultHumanize: Bool = UserDefaults.standard.bool(forKey: "humanize")
        humanize = defaultHumanize
    }
    
    func setPlayModeKey(_ content: String) {
        playModeKey = PitchClass(rawValue: content) ?? .C
    }
    func setVoicingBound(_ content: Int) {
        voicingBound = voicingLevels[content]?.note.midiNote ?? Note(.G, 3).midiNote
    }
}
