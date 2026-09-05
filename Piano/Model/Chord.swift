import Foundation

struct Chord: Hashable, Equatable, Codable {
    
    let pitchClass: PitchClass
    let intervals: Intervals
    let bassPitchClass: PitchClass
    
    init(_ pitchClass: PitchClass, intervals: Intervals, bassPitchClass: PitchClass? = nil) {
        self.pitchClass = pitchClass
        self.intervals = intervals
        self.bassPitchClass = bassPitchClass ?? pitchClass
    }
    
    
    init(_ pitchClass: PitchClass, _ quality: Quality, bassPitchClass: PitchClass? = nil) {
        self.pitchClass = pitchClass
        if let bassPitchClass {
            self.bassPitchClass = bassPitchClass
        } else {
            self.bassPitchClass = self.pitchClass
        }
        self.intervals = quality.intervals
    }
    
    static func chordsFrom(midiNotes: Set<Int>, in key: PitchClass) -> [Chord] {
        var chords: [Chord] = []
        var seenPitchClasses = Set<Int>()

        let midiNotes = midiNotes.sorted().filter { seenPitchClasses.insert($0 % 12).inserted }
        
        let bassPitchClass = PitchClass(number: (midiNotes.min() ?? 0) % 12, accidental: key.accidental)
        
        for rootMidiNote in midiNotes {
            let intervals = Set(midiNotes.map { (($0 - rootMidiNote) % 12 + 12) % 12 })
            let pitchClass = PitchClass(number: rootMidiNote % 12, accidental: key.accidental)
            if let quality = Quality(intervals: intervals) {
                chords.append(Chord(pitchClass, quality, bassPitchClass: bassPitchClass))
            }
        }
        
        return chords
    }
    


    var quality: Quality? {
        Quality(intervals: intervals)
    }
    var accidental: Accidental {
        pitchClass.accidental
    }
    
    func root(octave: Int = 2) -> Note {
        Note(pitchClass, octave)
    }
    
    func rootMidiNote(octave: Int = 2) -> Int {
        self.root(octave: octave).midiNote
    }
    func bass(octave: Int = 2) -> Note {
        Note(bassPitchClass, octave)
    }
    
    func bassMidiNote(octave: Int = 2) -> Int {
        self.bass(octave: octave).midiNote
    }
    var isSlashChord: Bool {
        bassPitchClass.number != pitchClass.number
    }
    var description: String {
        let slashChord = isSlashChord ? ("/" + bassPitchClass.description) : ""
        if let quality {
            return pitchClass.description + quality.description + slashChord
        } else {
            return pitchClass.description + intervals.description + slashChord
        }
    }
    

    var omittableIntervals: Set<Int> {
        var omittables: Set<Int> = []
        
        if intervals.count >= 4 {
            omittables.insert(0)
            omittables.insert(7)
        }
        
        if intervals.contains(5) {
            omittables.insert(2)
        }
        
        if intervals.contains(9) {
            omittables.insert(2)
            omittables.insert(5)
        }
        return omittables
    }
    var minIntervalCount: Int {
        return intervals.subtracting(omittableIntervals).count
    }
    func intervals(maxN: Int) -> Set<Int>? {
        guard minIntervalCount <= maxN else { return nil }
        
        var intervals = intervals

        let priority = [0, 7, 5, 2]
        let sortedOmittable = omittableIntervals.sorted {
            guard let i1 = priority.firstIndex(of: $0),
                  let i2 = priority.firstIndex(of: $1) else {
                return false
            }
            return i1 < i2
        }

        for value in sortedOmittable {
            if intervals.count <= maxN { break }
            intervals.remove(value)
        }

        return intervals
    }
    var allAcceptableIntervals: [Set<Int>] {
        allAcceptableSets(allNumbers: intervals, omittableNumbers: omittableIntervals)
    }
    
    func validate(midiNotes: Set<Int>) -> Bool {
        guard midiNotes.count >= 2 else { return false }
        
        let lowestNote = midiNotes.min()!
        guard self.bassPitchClass.number == lowestNote % 12 else { return false }
        
        var chordNotes = midiNotes
        if self.isSlashChord {
            chordNotes.remove(lowestNote)
        }
        
        let intervals = Set(chordNotes.map { ($0 - self.pitchClass.number) % 12 })

        if self.allAcceptableIntervals.contains(intervals) {
            return true
        }
        
        return false
    }

    
    static let C: Chord = .init(.C, .major,)
    static let Cm: Chord = .init(.C, .minor,)
}


extension Intervals {
    var description: String {
        var intervals = self
        intervals.remove(0)
        guard !intervals.isEmpty else { return "" }
        
        let has2 = self.contains(2)
        let hasb3 = self.contains(3)
        let has3 = self.contains(4)
        let has4 = self.contains(5)
        let hasb5 = self.contains(6)
        let has5 = self.contains(7)
        let has6 = self.contains(9)
        let hasb7 = self.contains(10)
        let has7 = self.contains(11)
        
        var base: String = ""
        if hasb3 {
            if hasb5 {
                base += "dim"
                intervals.remove(6)
            } else {
                base += "m"
            }
            intervals.remove(3)
        }
        if hasb7 {
            base += "7"
            intervals.remove(10)
        } else if has7 {
            base += "maj7"
            intervals.remove(11)
        } else if has6 {
            base += "6"
            intervals.remove(9)
        }
        
        if !hasb3, !has3 {
            if has4 {
                base += "sus4"
                intervals.remove(5)
            } else if has2 {
                base += "sus2"
                intervals.remove(2)
            } else if !has5 {
                base += "no3"
            } else if has5, base == "" {
                base += "5"
            }
        }
        intervals.remove(4)
        intervals.remove(7)
        let bracket = intervals.sorted().map { numberToAlteration[$0]! }.joined(separator: ",")
        
        return "\(base)\(bracket.isEmpty ? "" : "(\(bracket))")"
    }
}
