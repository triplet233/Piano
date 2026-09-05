import SwiftUI

enum BaseQuality: String, CaseIterable {
    case maj = "maj", min = "min", sus2 = "sus2", sus4 = "sus4"
    case five = "5", aug = "aug", dim = "dim"
    
    var intervals: Intervals {
        return switch self {
        case .maj: [4, 7]
        case .min: [3, 7]
        case .sus2: [2, 7]
        case .sus4: [5, 7]
        case .five: [7]
        case .aug: [4, 8]
        case .dim: [3, 6]
        }
    }
}

enum AddedQuality: String, CaseIterable {
    case flat5 = "b5", sharp5 = "#5", sixth = "6", seventh = "7", major7 = "maj7"
    case flat9 = "b9", ninth = "9", sharp9 = "#9", eleventh = "11", sharp11 = "#11"
    case flat13 = "b13", thirteenth = "13"
    
    var intervals: Intervals {
        return switch self {
        case .flat5: [6]
        case .sharp5: [8]
        case .sixth: [9]
        case .seventh: [10]
        case .major7: [11]
        case .flat9: [1]
        case .ninth: [2]
        case .sharp9: [3]
        case .eleventh: [5]
        case .sharp11: [6]
        case .flat13: [8]
        case .thirteenth: [9]
        }
    }
    
    var addSeventh: Bool {
        switch self {
        case .flat5, .sharp5, .sixth, .seventh, .major7: return false
        default: return true
        }
    }
    
    var addNinth: Bool {
        switch self {
        case .flat5, .sharp5, .sixth, .seventh, .major7, .flat9, .ninth, .sharp9: return false
        default: return true
        }
    }
}

enum ChordSelectorMode: String, CaseIterable {
    case wheel, picker, advanced
    
    var description: String {
        switch self {
        case .wheel: "wheel"
        case .picker: "picker"
        case .advanced: "advanced"
        }
    }
    static var availableCases: [ChordSelectorMode] {
    #if os(macOS)
        [.picker, .advanced]
    #else
        Self.allCases
    #endif
    }
    static var defaultMode: ChordSelectorMode {
    #if os(macOS)
        .picker
    #else
        .wheel
    #endif
    }
}

struct ChordSelectorView: View {
    
    @Binding var selectedChord: Chord?
    let mode: ChordSelectorMode
    
    @State private var selectedPitchClass: PitchClass? = .C
    @State private var selectedQuality: Quality = .major
    @State private var selectedBaseQuality = BaseQuality.maj
    @State private var selectedAddedQuality: Set<AddedQuality> = []
    @State private var selectedBassPitchClass: PitchClass? = nil

    
    @State private var showSubscriptionSheet: Bool = false
    
    @Environment(\.verticalSizeClass) private var sizeClass
    
    var intervals: Intervals {
        selectedBaseQuality.intervals
            .union(selectedAddedQuality.reduce(Intervals()) { result, addedQuality in result.union(addedQuality.intervals)
            })
            .union([0])
    }
    var chord: Chord? {
        guard let selectedPitchClass else { return nil }
        if mode == .advanced {
            return Chord(selectedPitchClass, intervals: intervals, bassPitchClass: selectedBassPitchClass)
        } else {
            return Chord(selectedPitchClass, selectedQuality, bassPitchClass: selectedBassPitchClass)
        }
    }
    
    var body: some View {
        VStack {

            GroupBox {
                HStack {
                    VStack {
                        if mode == .wheel {
                            Text("Root")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        Picker("Root Note", selection: $selectedPitchClass) {
                            Text("-")
                                .tag(nil as PitchClass?)
                            ForEach(PitchClass.allCases, id: \.self) {
                                Text($0.description)
                                    .tag($0)
                            }
                        }
                    }
                    if mode == .advanced {
                        Picker("Base Quality", selection: $selectedBaseQuality) {
                            ForEach(BaseQuality.allCases, id: \.self) { quality in
                                Text(quality.rawValue)
                            }
                        }
                    } else {
                        VStack {
                            if mode == .wheel {
                                Text("Quality")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            Picker("Quality", selection: $selectedQuality) {
                                ForEach(Quality.allCases, id: \.self) { quality in
                                    Text(quality.description)
                                }
                            }
                        }
                    }
                    if mode != .wheel {
                        Spacer()
                        Text("Bass")
                    }
                    VStack {
                        if mode == .wheel {
                            Text("Bass")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        Picker("Bass Note", selection: $selectedBassPitchClass) {
                            Text("-")
                                .tag(nil as PitchClass?)
                            ForEach(PitchClass.allCases, id: \.self) {
                                Text($0.description)
                                    .tag($0)
                            }
                        }
                    }
                }
                #if os(iOS)
                .if(mode == .wheel) {
                    $0.pickerStyle(.wheel)
                }
                #endif
                .buttonStyle(.glass)
            }
            if mode == .advanced {
                GroupBox {
                    FlowLayout {
                        ForEach(AddedQuality.allCases, id: \.self) { quality in
                            Button {
                                if selectedAddedQuality.contains(quality) {
                                    if quality.addSeventh {
                                        selectedAddedQuality.remove(.seventh)
                                    }
                                    if quality.addNinth {
                                        selectedAddedQuality.remove(.ninth)
                                    }
                                    selectedAddedQuality.remove(quality)
                                } else {
                                    if quality.addSeventh {
                                        selectedAddedQuality.insert(.seventh)
                                    }
                                    if quality.addNinth {
                                        selectedAddedQuality.insert(.ninth)
                                    }
                                    selectedAddedQuality.insert(quality)
                                }
                            } label: {
                                if selectedBaseQuality == .dim, quality == .sixth {
                                    Text("dim7")
                                } else {
                                    Text(quality.rawValue)
                                }
                            }
                            .if(selectedAddedQuality.contains(quality)) {
                                $0.buttonStyle(.glassProminent)
                            }
                            .if(!selectedAddedQuality.contains(quality)) {
                                $0.buttonStyle(.glass)
                            }
                        }
                    }
                }
            }
 
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
        }
        .contentTransition(.symbolEffect(.replace))
        .onChange(of: chord) { _, newValue in
            selectedChord = newValue
        }
    }
    
}

#Preview {
    @Previewable @State var selectedChord: Chord? = nil
    
    ChordSelectorView(selectedChord: $selectedChord, mode: .advanced)
}
