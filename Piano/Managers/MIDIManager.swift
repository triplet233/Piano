import Observation
import Foundation

enum MIDIEvent {
    case noteOn(Int)
    case noteOff(Int)
}


@MainActor
@Observable
final class MIDIManager {

    private let engine = MIDIEngine()

    var isConnected: Bool = false
    var sourceList: [String] = []
    var activeMidiNotes: Set<Int> = []
    var sustainIsOn = false

    private var continuations: [UUID: AsyncStream<MIDIEvent>.Continuation] = [:]


    func setUpEngine(output: Sampler) {
        engine.onNoteOn = { [weak self] note, velocity in
            guard let self else { return }
            output.startNote(note, withVelocity: velocity)
            
            Task { @MainActor in
                self.activeMidiNotes.insert(note)
                for continuation in self.continuations.values {
                    continuation.yield(.noteOn(note))
                }
            }
        }
        engine.onNoteOff = { [weak self] note in
            guard let self else { return }
            output.stopNote(note)
            
            Task { @MainActor in

                self.activeMidiNotes.remove(note)
                for continuation in self.continuations.values {
                    continuation.yield(.noteOff(note))
                }
            }
        }
        engine.onSustain = { [weak self] isOn in
            Task { @MainActor in
                if isOn {
                    output.sustainPedalOn()
                } else {
                    output.sustainPedalOff()
                }
                self?.sustainIsOn = isOn
            }
        }
        engine.onSourcesChanged = { [weak self] names, connected in
            Task { @MainActor in
                self?.sourceList = names
                self?.isConnected = connected
            }
        }
    }

    func noteStream() -> AsyncStream<MIDIEvent> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in
                    self?.continuations[id] = nil
                }
            }
        }
    }
}
