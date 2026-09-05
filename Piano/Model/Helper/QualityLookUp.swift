let qualityToName: [Quality : String] = [
    .power                            : "5",
    .suspended2nd                     : "sus2",
    .diminished                       : "dim",
    .minor                            : "m",
    .major                            : "",
    .augmented                        : "aug",
    .suspended4th                     : "sus4",
    
    .minorSixth                       : "m6",
    .majorSixth                       : "6",
    .sixNinth                         : "6/9",
    .minorSixNinth                    : "m6/9",
    
    .minorSeventh                     : "m7",
    .dominantSeventh                  : "7",
    .majorSeventh                     : "maj7",
    .diminishedSeventh                : "dim7",
    .halfDiminishedSeventh            : "m7b5",
    .minorMajorSeventh                : "mMaj7",
    .augmentedSeventh                 : "aug7",
    .dominantSeventhWithSuspended4th  : "7sus4",
    .alteredSeventh                   : "7alt",
    
    .minorAdded9th                    : "madd9",
    .majorAdded9th                    : "add9",
    .minorNinth                       : "m9",
    .dominantNinth                    : "9",
    .majorNinth                       : "maj9",
    
    .minorAddedEleventh               : "madd11",
    .majorAddedEleventh               : "add11",
    .dominantEleventh                 : "11",
    .minorEleventh                    : "m11",
    .majorEleventh                    : "maj11",
    
    .dominantThirteenth               : "13",
    .minorThirteenth                  : "m13"
]



let qualityToIntervals: [Quality : Intervals]  = [
    .power                            :  [0, 7],
    .suspended2nd                     :  [0, 2, 7],
    .minor                            :  [0, 3, 7],
    .major                            :  [0, 4, 7],
    .suspended4th                     :  [0, 5, 7],
    .diminished                       :  [0, 3, 6],
    .augmented                        :  [0, 4, 8],
    
    .minorSixth                       :  [0, 3, 7, 9],
    .majorSixth                       :  [0, 4, 7, 9],
    .sixNinth                         :  [0, 2, 4, 9],
    .minorSixNinth                    :  [0, 2, 3, 9],
    
    .minorSeventh                     :  [0, 3, 7, 10],
    .minorMajorSeventh                :  [0, 3, 7, 11],
    .dominantSeventh                  :  [0, 4, 7, 10],
    .majorSeventh                     :  [0, 4, 7, 11],
    .dominantSeventhWithSuspended4th  :  [0, 5, 7, 10],
    .diminishedSeventh                :  [0, 3, 6, 9],
    .halfDiminishedSeventh            :  [0, 3, 6, 10],
    .augmentedSeventh                 :  [0, 4, 8, 10],
    .alteredSeventh                   :  [0, 1, 4, 10],
    
    .minorAdded9th                    :  [0, 2, 3, 7],
    .majorAdded9th                    :  [0, 2, 4, 7],
    .dominantNinth                    :  [0, 2, 4, 7, 10],
    .majorNinth                       :  [0, 2, 4, 7, 11],
    .minorNinth                       :  [0, 2, 3, 7, 10],
    
    .minorAddedEleventh               :  [0, 3, 5, 7],
    .majorAddedEleventh               :  [0, 4, 5, 7],
    .dominantEleventh                 :  [0, 2, 4, 5, 7, 10],
    .minorEleventh                    :  [0, 2, 3, 5, 7, 10],
    .majorEleventh                    :  [0, 2, 4, 5, 7, 11],
    
    .dominantThirteenth               :  [0, 2, 4, 5, 7, 9, 10],
    .minorThirteenth                  :  [0, 2, 3, 5, 7, 9, 10]
]

let IntervalsToQuality: [Intervals: Quality] = [
    [0, 7]             : .power,
    [0, 2, 7]          : .suspended2nd,
    [0, 3, 6]          : .diminished,
    [0, 3, 7]          : .minor,
    [0, 4, 7]          : .major,
    [0, 4, 8]          : .augmented,
    [0, 5, 7]          : .suspended4th,
    
    [0, 2, 4, 9]       : .sixNinth,
    [0, 2, 3, 9]       : .minorSixNinth,
    [0, 3, 7, 9]       : .minorSixth,
    [0, 4, 7, 9]       : .majorSixth,
    
    [0, 3, 6, 9]       : .diminishedSeventh,
    [0, 3, 6, 10]      : .halfDiminishedSeventh,

    [0, 3, 11]         : .minorMajorSeventh,
    [0, 3, 7, 11]      : .minorMajorSeventh,
    [0, 4, 8, 10]      : .augmentedSeventh,
    [0, 5, 10]         : .dominantSeventhWithSuspended4th,
    [0, 5, 7, 10]      : .dominantSeventhWithSuspended4th,
    [0, 3, 10]         : .minorSeventh,
    [0, 3, 7, 10]      : .minorSeventh,
    [0, 4, 10]         : .dominantSeventh,
    [0, 4, 7, 10]      : .dominantSeventh,
    [0, 4, 11]         : .majorSeventh,
    [0, 4, 7, 11]      : .majorSeventh,
    [0, 1, 4, 10]      : .alteredSeventh,
    [0, 1, 4, 6, 10]   : .alteredSeventh,
    
    [0, 2, 3, 7]       : .minorAdded9th,
    [0, 2, 4, 7]       : .majorAdded9th,
    [0, 2, 3, 10]      : .minorNinth,
    [0, 2, 3, 7, 10]   : .minorNinth,
    [0, 2, 4, 10]      : .dominantNinth,
    [0, 2, 4, 7, 10]   : .dominantNinth,
    [0, 2, 4, 11]      : .majorNinth,
    [0, 2, 4, 7, 11]   : .majorNinth,
    

    [0, 4, 5, 10]            : .dominantEleventh,
    [0, 4, 5, 7, 10]         : .dominantEleventh,
    [0, 2, 4, 5, 10]         : .dominantEleventh,
    [0, 2, 4, 5, 7, 10]      : .dominantEleventh,
    [0, 3, 5, 10]            : .minorEleventh,
    [0, 2, 3, 5, 10]         : .minorEleventh,
    [0, 3, 5, 7, 10]         : .minorEleventh,
    [0, 2, 3, 5, 7, 10]      : .minorEleventh,
    [0, 3, 5, 7]             : .minorAddedEleventh,
    [0, 4, 5, 7]             : .majorAddedEleventh,
    [0, 4, 5, 11]            : .majorEleventh,
    [0, 2, 4, 5, 11]         : .majorEleventh,
    [0, 2, 4, 5, 7, 11]      : .majorEleventh,
    
    [0, 4, 9, 10]            : .dominantThirteenth,
    [0, 4, 5, 9, 10]         : .dominantThirteenth,
    [0, 4, 7, 9, 10]         : .dominantThirteenth,
    [0, 2, 4, 9, 10]         : .dominantThirteenth,
    [0, 2, 4, 7, 9, 10]      : .dominantThirteenth,
    [0, 2, 4, 5, 9, 10]      : .dominantThirteenth,
    [0, 2, 4, 5, 7, 9, 10]   : .dominantThirteenth,
    [0, 3, 9, 10]            : .minorThirteenth,
    [0, 3, 5, 9, 10]         : .minorThirteenth,
    [0, 3, 7, 9, 10]         : .minorThirteenth,
    [0, 2, 3, 9, 10]         : .minorThirteenth,
    [0, 2, 3, 7, 9, 10]      : .minorThirteenth,
    [0, 2, 3, 5, 9, 10]      : .minorThirteenth,
    [0, 2, 3, 5, 7, 9, 10]   : .minorThirteenth,
    
]
