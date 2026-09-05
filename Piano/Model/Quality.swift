enum Quality: String, CaseIterable, Sendable, Codable, Equatable {
    case power, suspended2nd, diminished, minor, major, augmented, suspended4th,
         minorSeventh, dominantSeventh, majorSeventh, minorMajorSeventh,
         diminishedSeventh, halfDiminishedSeventh,
         augmentedSeventh, dominantSeventhWithSuspended4th, alteredSeventh,
         minorSixth, majorSixth, sixNinth, minorSixNinth,
         minorAdded9th, majorAdded9th, minorNinth, dominantNinth, majorNinth,
         minorAddedEleventh, majorAddedEleventh, minorEleventh, dominantEleventh, majorEleventh,
         minorThirteenth, dominantThirteenth
    
    
    init?(intervals: Set<Int>) {
        guard let quality = IntervalsToQuality[intervals] else { return nil }
        self = quality
    }
    
    var intervals: Set<Int> {
        Set(qualityToIntervals[self]!)
    }
    
    var description: String {
        qualityToName[self]!
    }
}

typealias Intervals = Set<Int>
