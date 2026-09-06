import Foundation

enum Difficulty: String, CaseIterable {
    case easy, medium, hard, impossible
    var leaderboardID: String {
        switch self {
        case .easy: "grp.easy_gdfs"
        case .medium: "grp.medium_dfsdfs"
        case .hard: "grp.hard_uefiw"
        case .impossible: "grp.impossible_dsfdfsa"
        }
        
    }
    
    var name: String {
        self.rawValue.localizedCapitalized
    }
    
    func generateRandomChord() -> Chord {
        
        switch self {
        case .easy:
            let randomQuality = generateRandom(probabilities: easyModeQualityProbabilities)!
            
            let randomPitchClass = PitchClass(
                number: Int.random(in: 0...11),
                accidental: Accidental.allCases.randomElement()!
            )
            
            return Chord(randomPitchClass, randomQuality)
            
        case .medium:
            let randomQuality = generateRandom(probabilities: mediumModeQualityProbabilities)!
            
            let randomPitchClass = PitchClass(
                number: Int.random(in: 0...11),
                accidental: Accidental.allCases.randomElement()!
            )
            
            return Chord(randomPitchClass, randomQuality)
            
        case .hard:
            let randomQuality = generateRandom(probabilities: hardModeQualityProbabilities)!
            
            let randomPitchClass = PitchClass(
                number: Int.random(in: 0...11),
                accidental: Accidental.allCases.randomElement()!
            )
            
            let randomBassPitchClassNumberSet = randomQuality.intervals.map { ($0 + randomPitchClass.number) % 12 }
            
            let randomBassPitchClassCandidate = PitchClass(
                number: randomBassPitchClassNumberSet.randomElement()!,
                accidental: Accidental.allCases.randomElement()!
            )
            
            let randomBassPitchClass = Double.random(in: 0..<1) < 0.2 ? randomBassPitchClassCandidate : nil
            
            return Chord(randomPitchClass, randomQuality, bassPitchClass: randomBassPitchClass)
            
        case .impossible:
            let randomQuality = generateRandom(probabilities: hardModeQualityProbabilities)!
            
            let randomPitchClass = PitchClass(
                number: Int.random(in: 0...11),
                accidental: Accidental.allCases.randomElement()!
            )
            
            let randomBassPitchClassNumberSet = randomQuality.intervals.map { ($0 + randomPitchClass.number) % 12 }
            
            let randomBassPitchClassCandidate = PitchClass(
                number: randomBassPitchClassNumberSet.randomElement()!,
                accidental: Accidental.allCases.randomElement()!
            )
            
            let randomBassPitchClass = Double.random(in: 0..<1) < 0.3 ? randomBassPitchClassCandidate : nil

            return Chord(randomPitchClass, randomQuality, bassPitchClass: randomBassPitchClass)
        }

    }
}
