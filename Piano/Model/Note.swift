
struct Note: Hashable {
    let midiNote: Int
    let accidental: Accidental
    
    init (midiNote: Int, accidental: Accidental = .sharp) {
        self.midiNote = midiNote
        self.accidental = accidental
    }
    init(_ pitchClass: PitchClass, _ octave: Int = 3) {
        self.midiNote = pitchClass.number + 12 * (octave + 1)
        self.accidental = pitchClass.accidental
    }
    var pitchClass: PitchClass {
        .init(number: midiNote % 12, accidental: accidental)

    }
    var octave: Int {
        return midiNote  / 12 - 1
    }
    var description: String {
        return pitchClass.description + String(octave)
    }
}

enum PitchClass: String, CaseIterable, Codable, Equatable {
    case Ab, A, As, Bb, B, C, Cs, Db, D, Ds, Eb, E, F, Fs, Gb, G, Gs
    
    init(number: Int, accidental: Accidental? = nil) {
        if accidental == .flat {
            self = numberToPitchClassFlat[number]!
        } else {
            self = numberToPitchClassSharp[number]!
        }
    }
    var number: Int {
        pitchClassToNumber[self]!
    }
    var description: String {
        pitchClassToName[self]!
    }
    var accidental: Accidental {
        switch self {
        case .C, .G, .D, .A, .E, .B, .Fs, .Cs, .Gs, .Ds, .As: .sharp
        default: .flat
        }
    }
    
    func last(semitone: Bool = false) -> PitchClass {
        if semitone {
            pitchClassToLast[self]!.0
        } else {
            pitchClassToLast[self]!.1
        }
        
    }
    
    func transpose(isUp: Bool, to key: PitchClass) -> PitchClass {
        .init(number: isUp ? (self.number + 1) % 12 : (self.number - 1 + 12) % 12, accidental: key.accidental)
    }
    
    func scaleDegree(to pitchClass: PitchClass) -> Int {
        let diff = self.number - pitchClass.number
        if diff < 0 {
            return 12 + diff
        } else {
            return diff
        }
    }
    
    
}

enum Accidental: String, CaseIterable {
    case sharp, flat
}
