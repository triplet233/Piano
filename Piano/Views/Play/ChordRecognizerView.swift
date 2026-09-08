import SwiftUI

struct ChordRecognizerView: View {
    
    let vpiano: VirtualPianoManager
    let isLarge: Bool
    let sustainButton: SustainButton
    
    @State private var isPlaying: Bool = false
    
    @Environment(\.touchPlay) private var touchPlay
    @Environment(\.appState) private var appState
    
    var chords: [Chord] {
        let detectedChords = Chord.chordsFrom(
            midiNotes: vpiano.highlightedMidiNotes,
            in: appState.playModeKey
        )

        return appState.identifyMultipleChords
            ? detectedChords
            : Array(detectedChords.prefix(1))
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                Spacer()
                
                if chords.isEmpty {
                    Text("-")
                        .foregroundStyle(.secondary)
                }
                
                ForEach(chords, id: \.self) { chord in
                    Text(chord.description)
                }
                .foregroundStyle(Color.accentColor)
                .font(isLarge ? .system(size: 72) : .largeTitle)
                .monospaced()
                .scaleEffect(isPlaying ? 0.9 : 1)
                .animation(.easeOut(duration: 0.1), value: isPlaying)
                .contentShape(Rectangle())
                .gesture(TapChordGesture(isPressed: $isPlaying, notes: vpiano.highlightedMidiNotes, touchPlay: touchPlay))
                    
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
         
                    playNotesTaskInfo
                    Spacer()
                    sustainButton
                    MetronomeButton()
                    
                }
                .monospaced()
                .padding()
            }
        }
    }
    
    
    var playNotesTaskInfo: some View {
        Group {
            if !vpiano.highlightedMidiNotes.isEmpty {
                Text("Playing: \(Array(vpiano.highlightedMidiNotes).sorted { $0 < $1 }.map { Note(midiNote: $0) }.map { $0.description }.joined(separator: ", "))")
                    .foregroundStyle(Color.accentColor)
                    .lineLimit(1)
            } else {
                Text("Playing: -")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
//    ChordRecognizerView()
}
