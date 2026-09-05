import Observation

@MainActor
@Observable
class VirtualPianoManager {
    
    var highlightedMidiNotes: Set<Int> = []
    var keepNote: Bool = false {
        didSet {
            output?.stopAllNotes()
            highlightedMidiNotes.removeAll()
        }
    }
    private var output: Sampler?
    private var listenTask: Task<Void, Never>?
    
    func start(midi: MIDIManager, output: Sampler) {
        self.output = output
        
        listenTask?.cancel()
        listenTask = Task { [weak self] in
            guard let self else { return }
            for await midiEvent in midi.noteStream() {
                switch midiEvent {
                case .noteOn(let note):
                    highlightedMidiNotes.insert(note)
                case .noteOff(let note):
                    highlightedMidiNotes.remove(note)
                }
            }
        }
    }
    
    func touchDown(on midiNote: Int) {
        if highlightedMidiNotes.contains(midiNote) {
            output?.stopNote(midiNote)
            highlightedMidiNotes.remove(midiNote)
        } else {
            output?.startNote(midiNote)
            highlightedMidiNotes.insert(midiNote)
        }
    }
    
    func touchUp(on midiNote: Int) {
        if !keepNote {
            output?.stopNote(midiNote)
            highlightedMidiNotes.remove(midiNote)
        }
    }
    isolated deinit {
        listenTask?.cancel()
    }
}



