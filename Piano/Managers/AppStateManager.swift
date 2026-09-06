import Foundation

enum Constants {
    
    static let bpmRange = 60...150
}

class AppStateManager {

    var playModeKey: PitchClass

    
    init() {
        let defaultPlayModeKey = UserDefaults.standard.string(forKey: "playModeKey") ?? "C"
        playModeKey = PitchClass(rawValue: defaultPlayModeKey) ?? .C

    }
    
    func setPlayModeKey(_ content: String) {
        playModeKey = PitchClass(rawValue: content) ?? .C
    }

}
