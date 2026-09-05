func generateRandom<T>(probabilities: [(value: T, weight: Double)]) -> T? {
    guard !probabilities.isEmpty else { return nil }

    let totalWeight = probabilities.reduce(0) { $0 + $1.weight }
    guard totalWeight > 0 else { return nil }

    let randomDouble = Double.random(in: 0..<totalWeight)

    var cumulative: Double = 0
    for (value, weight) in probabilities {
        cumulative += weight
        if randomDouble < cumulative {
            return value
        }
    }

    // Fallback — should not hit this if weights > 0
    return probabilities.last?.value
}


let easyModeQualityProbabilities: [(value: Quality, weight: Double)] = [
    (.minor,            10),
    (.major,            10),
    (.suspended2nd,     3),
    (.suspended4th,     3),
    (.diminished,       1),
    (.augmented,        1),
    (.power,            2)
]

let mediumModeQualityProbabilities: [(value: Quality, weight: Double)] = [
    (.power,                            2),
    (.suspended2nd,                     2),
    (.minor,                            2),
    (.major,                            2),
    (.suspended4th,                     2),
    (.diminished,                       1),
    (.augmented,                        1),
    (.minorSixth,                       3),
    (.majorSixth,                       3),
    (.sixNinth,                         1),
    (.minorSixNinth,                    1),
    (.minorSeventh,                     3),
    (.dominantSeventh,                  3),
    (.majorSeventh,                     3),
    (.dominantSeventhWithSuspended4th,  1),
    (.halfDiminishedSeventh,            1),
    (.majorAdded9th,                    2),
    (.majorAddedEleventh,               2)
]

let hardModeQualityProbabilities: [(value: Quality, weight: Double)] = [
    (.power,                              1),
    (.suspended2nd,                       1),
    (.minor,                              1),
    (.major,                              1),
    (.suspended4th,                       1),
    (.diminished,                         1),
    (.augmented,                          1),
    
    (.minorSixth,                         1),
    (.majorSixth,                         1),
    (.sixNinth,                           1),
    (.minorSixNinth,                      1),
    
    (.minorSeventh,                       1),
    (.minorMajorSeventh,                  1),
    (.dominantSeventh,                    1),
    (.majorSeventh,                       1),
    (.dominantSeventhWithSuspended4th,    1),
    (.diminishedSeventh,                  1),
    (.halfDiminishedSeventh,              1),
    (.augmentedSeventh,                   1),
    (.alteredSeventh,                     1),
    
    (.minorAdded9th,                      1),
    (.majorAdded9th,                      1),
    (.dominantNinth,                      1),
    (.majorNinth,                         1),
    (.minorNinth,                         1),
    (.majorAddedEleventh,                 1),
    (.dominantEleventh,                   1),
    (.minorEleventh,                      1),
    (.dominantThirteenth,                 1),
    (.minorThirteenth,                    1)
]
