
let numberToPitchClassSharp: [Int: PitchClass] = [
    0   :  .C   ,
    1   :  .Cs  ,
    2   :  .D   ,
    3   :  .Ds  ,
    4   :  .E   ,
    5   :  .F   ,
    6   :  .Fs  ,
    7   :  .G   ,
    8   :  .Gs  ,
    9   :  .A   ,
    10  :  .As  ,
    11  :  .B   ,
]

let numberToPitchClassFlat: [Int: PitchClass] = [
    0   :  .C   ,
    1   :  .Db  ,
    2   :  .D   ,
    3   :  .Eb  ,
    4   :  .E   ,
    5   :  .F   ,
    6   :  .Gb  ,
    7   :  .G   ,
    8   :  .Ab  ,
    9   :  .A   ,
    10  :  .Bb  ,
    11  :  .B   ,
]

let pitchClassToNumber: [PitchClass: Int] = [
    .C   :  0   ,
    .Cs  :  1   ,
    .Db  :  1   ,
    .D   :  2   ,
    .Ds  :  3   ,
    .Eb  :  3   ,
    .E   :  4   ,
    .F   :  5   ,
    .Fs  :  6   ,
    .Gb  :  6   ,
    .G   :  7   ,
    .Gs  :  8   ,
    .Ab  :  8   ,
    .A   :  9   ,
    .As  :  10  ,
    .Bb  :  10  ,
    .B   :  11
]

let pitchClassToNext: [PitchClass: (PitchClass, PitchClass)] = [
    .C   :  (.Db,  .D)  ,
    .Cs  :  (.D, . Ds)  ,
    .Db  :  (.Eb, .Eb)  ,
    .D   :  (.Eb,  .E)  ,
    .Ds  :  (.E,   .E)  ,
    .Eb  :  (.F,   .F)  ,
    .E   :  (.F,  .Fs)  ,
    .F   :  (.Gb, . G)  ,
    .Fs  :  (.G,  .Gs)  ,
    .Gb  :  (.Ab, .Ab)  ,
    .G   :  (.Ab,  .A)  ,
    .Gs  :  (.A,  .As)  ,
    .Ab  :  (.Bb, .Bb)  ,
    .A   :  (.Bb,  .B)  ,
    .As  :  (.B,   .B)  ,
    .Bb  :  (.C,   .C)  ,
    .B   :  (.C,  .Cs)
]

let pitchClassToLast: [PitchClass: (PitchClass, PitchClass)] = [
    .C   :  (.B,  .Bb)  ,
    .Cs  :  (.B,   .B)  ,
    .Db  :  (.C,   .C)  ,
    .D   :  (.Cs,  .C)  ,
    .Ds  :  (.Cs, .Cs)  ,
    .Eb  :  (.D,  .Db)  ,
    .E   :  (.Ds,  .D)  ,
    .F   :  (.E, . Eb)  ,
    .Fs  :  (.E,   .E)  ,
    .Gb  :  (.F,   .F)  ,
    .G   :  (.Fs,  .F)  ,
    .Gs  :  (.Fs, .Fs)  ,
    .Ab  :  (.G,  .Gb)  ,
    .A   :  (.Gs,  .G)  ,
    .As  :  (.Gs, .Gs)  ,
    .Bb  :  (.A,  .Ab)  ,
    .B   :  (.As,  .A)
]
    

let pitchClassToName: [PitchClass: String] = [
    .C   :  "C"   ,
    .Cs  :  "C#"  ,
    .Db  :  "Db"  ,
    .D   :  "D"   ,
    .Ds  :  "D#"  ,
    .Eb  :  "Eb"  ,
    .E   :  "E"   ,
    .F   :  "F"   ,
    .Fs  :  "F#"  ,
    .Gb  :  "Gb"  ,
    .G   :  "G"   ,
    .Gs  :  "G#"  ,
    .Ab  :  "Ab"  ,
    .A   :  "A"   ,
    .As  :  "A#"  ,
    .Bb  :  "Bb"  ,
    .B   :  "B"
]


let numberToAlteration: [Int: String] = [
    1   :   "b9",
    2   :   "9",
    3   :   "#9",
    4   :   "3",
    5   :   "11",
    6   :   "#11",
    7   :   "5",
    8   :   "b13",
    9   :   "13",
    10  :   "7",
    11  :   "maj7"
]
