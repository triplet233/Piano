struct Voicing: Equatable {
    let chord: Chord
    let bound: Int
    let n: Int
    
    init(chord: Chord, bound: Int, minN: Int = 3) {
        
        self.chord = chord
        self.bound = min(max(bound, Note(.G, 2).midiNote), Note(.G, 4).midiNote)
        self.n = max(minN, chord.minIntervalCount)
    }
    
    init?(chord: Chord, bound: Int, n: Int = 3) {
        guard chord.minIntervalCount <= n else { return nil }
        
        self.chord = chord
        self.bound = min(max(bound, Note(.G, 2).midiNote), Note(.G, 4).midiNote)
        self.n = n
    }
    
    var midiNotes: Set<Int> {

        var results: Set<Int> = []
        var candidate = bound
        let origIntervals = chord.intervals(maxN: n)!
        var intervals = origIntervals
        
        // Make sure all intervals filled
        while intervals.count > 0 {
            let interval = mod12(candidate - chord.pitchClass.number)

            if intervals.contains(interval) {
                results.insert(candidate)
                intervals.remove(interval)
            }
            candidate += 1
        }
        
        // Fill the remaining
        while results.count < n {
            let interval = mod12(candidate - chord.pitchClass.number)
            
            if origIntervals.contains(interval) {
                results.insert(candidate)
            }
            candidate += 1
        }
        
        return results
    }
    
    var bassMidiNote: Int {

        var candidate = bound - 6

        while candidate % 12 != chord.bassPitchClass.number {
            candidate -= 1
        }
        return candidate
    }
    
    var allMidiNotes: Set<Int> {
        midiNotes.union([bassMidiNote])
    }

    private var next: Voicing {
        let newBound = midiNotes.min()! + 1
        
        return Voicing(chord: chord, bound: newBound, n: self.n)!
    }
    
    private var before: Voicing {

        var newBound = bound
        var candidate = self
        
        while candidate.midiNotes == midiNotes {
            newBound -= 1
            candidate = Voicing(chord: chord, bound: newBound, n: self.n)!
            if newBound < Note(.G, 2).midiNote { break }
        }
        return candidate
    }
    
    private func mod12(_ x: Int) -> Int {
        let r = x % 12
        return r >= 0 ? r : r + 12
    }
}

extension Voicing {
    private var isValidSpacing: Bool {
        
        let numbers = midiNotes.sorted()
        
        for i in 1..<numbers.count {
            let diff = numbers[i] - numbers[i - 1]
            if !(diff >= 2 && diff <= 7) {
                return false
            }
        }
        return true
    }

    
    var getValid: Voicing {
        var result: Voicing!
        
        if isValidSpacing {
            result = self
        } else {
            let next = nextValid
            if next != self {
                result = nextValid
            } else {
                result = lastValid
            }
        }
        if !result.isValidSpacing, self.isValidSpacing2 {
            result = self
        }
        return result
    }
    var nextValid: Voicing {
        let original = self
        var candidate = self.next
        var result: Voicing!
        
        while !candidate.isValidSpacing {
            let next = candidate.next
            
            if candidate != next {
                candidate = next
            } else {
                result = original
                break
            }
        }
        result = candidate
        if result == original || result.midiNotes.max() ?? 99 - result.bassMidiNote > 24 {
            result = original.nextValid2
        }
        
        return result
    }
    
    var lastValid: Voicing {
        let original = self
        var candidate = self.before
        var result: Voicing!
        
        while !candidate.isValidSpacing {
            let last = candidate.before
            if candidate != last {
                candidate = last
            } else {
                result = original
                break
            }
            
        }
        result = candidate
        if result == original || result.midiNotes.max() ?? 99 - result.bassMidiNote > 24 {
            result = original.lastValid2
        }
        return result
    }
    
    private var isValidSpacing2: Bool {
        
        let numbers = midiNotes.sorted()
        
        for i in 1..<numbers.count {
            let diff = numbers[i] - numbers[i - 1]
            if !(diff <= 7) {
                return false
            }
        }
        return true
    }

    var nextValid2: Voicing {
        let original = self
        var candidate = self.next
        
        
        while !candidate.isValidSpacing2 {
            let next = candidate.next
            
            if candidate != next {
                candidate = next
            } else {
                return original
            }
        }
        return candidate

    }
    
    var lastValid2: Voicing {
        let original = self
        var candidate = self.before
        
        while !candidate.isValidSpacing2 {
            let last = candidate.before
            if candidate != last {
                candidate = last
            } else {
                return original
            }
            
        }
        return candidate
    }

}
