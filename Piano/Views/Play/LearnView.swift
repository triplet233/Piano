import SwiftUI

struct LearnView: View {
    let vpiano: VirtualPianoManager
    
    @State private var selectedChord: Chord?
    @State private var n: Int = 3
    @State private var voicing: Voicing? = nil
    @State private var bound: Int = Note(.G, 3).midiNote
    @State private var isPlaying: Bool = false
    
    @Environment(\.touchPlay) private var touchPlay
    @Environment(\.verticalSizeClass) private var sizeClass
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Text(selectedChord != nil ? selectedChord!.description : "-")
                        .font(.title)
                        .monospaced()
                    Image(systemName: "speaker.wave.2")
                }
                .padding()
                .padding(.horizontal, 6)
                .glassEffect()
                .foregroundStyle(selectedChord != nil ? Color.accentColor : .secondary)
                .scaleEffect(isPlaying ? 0.9 : 1)
                .animation(.easeOut(duration: 0.1), value: isPlaying)
                .contentShape(Rectangle())
                .gesture(TapChordGesture(isPressed: $isPlaying, notes: voicing?.allMidiNotes ?? [], touchPlay: touchPlay))

                Spacer()

                VStack(alignment: .trailing) {
  
                    HStack {
                        Button { n = min(max(n - 1, 2), 6) } label: {
                            Image(systemName: "arrow.left")
                        }
                        .keyboardShortcut(.upArrow, modifiers: [])
                        .help("Less notes")
                        
                        Text(String(n)).frame(width: 20)
                        
                        Button { n = min(max(n + 1, 2), 6) } label: {
                            Image(systemName: "arrow.right")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                        .help("More notes")
                    }
                    
                    HStack {

                        Button {
                            let newVoicing = voicing?.lastValid
                            voicing = newVoicing
                            if let newBound = newVoicing?.bound {
                                bound = newBound - 2
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                        .help("Lower voicing")
                        
                        Image(systemName: "waveform").frame(width: 20)
                        
                        Button {
                            let newVoicing = voicing?.nextValid

                            voicing = newVoicing
                            if let newBound = newVoicing?.bound {
                                bound = newBound - 2
                            }
                        } label: {
                            Image(systemName: "arrow.right")
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                        .help("Higher voicing")
                    }
                }
                .buttonStyle(.glass)
            }
            
            
            
            ChordSelectorView(selectedChord: $selectedChord, mode: ChordSelectorMode.defaultMode)
                .padding(.top, 8)

        }
        .padding()
        .background(.background)

        .onAppear {
            selectedChord = .C
        }
        .onDisappear {
            vpiano.highlightedMidiNotes.removeAll()
        }
        .onChange(of: n) { oldValue, newValue in
            if let selectedChord, let newVoicing = Voicing(chord: selectedChord, bound: bound, n: newValue) {
                voicing = newVoicing.getValid
            } else {
                n = oldValue
            }
        }
        .onChange(of: selectedChord) { _, newValue in
            if let newValue {
                let minN = newValue.minIntervalCount
                n = max(n, minN)
                voicing = Voicing(chord: newValue, bound: bound, n: n)?.getValid
            } else {
                voicing = nil
            }
        }
        .onChange(of: voicing) { _, newValue in
            touchPlay?.stopTask()
            if let newValue {
                vpiano.highlightedMidiNotes = newValue.allMidiNotes
            }
        }
       
    }
}

#Preview {
    LearnView(vpiano: .init())
}
