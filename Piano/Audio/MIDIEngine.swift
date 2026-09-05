import CoreMIDI

final class MIDIEngine {
    private var midiClient: MIDIClientRef = 0
    private var inputPort: MIDIPortRef = 0

    // Callback hooks the MainActor manager sets to receive events.
    // These closures are invoked on CoreMIDI's realtime thread — keep them fast.
    var onNoteOn: ((Int, Int) -> Void)?
    var onNoteOff: ((Int) -> Void)?
    var onSustain: ((Bool) -> Void)?
    var onSourcesChanged: (([String], Bool) -> Void)?

    init() {
        if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
            setupMIDI()
        }
    }

    private func setupMIDI() {
        let clientStatus = MIDIClientCreateWithBlock("MIDI Receiver" as CFString, &midiClient) { [weak self] notificationPtr in
            let messageID = notificationPtr.pointee.messageID
            switch messageID {
            case .msgObjectAdded, .msgObjectRemoved:
//                DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.connectToAllSources()
//                }
            default:
                break
            }
        }

        guard clientStatus == noErr else {
            print("Error creating MIDI client: \(clientStatus)")
            return
        }

        let portStatus = MIDIInputPortCreateWithProtocol(midiClient, "Input Port" as CFString, ._1_0, &inputPort) { [weak self] eventListPtr, _ in
            self?.handleEventList(eventListPtr)
        }

        guard portStatus == noErr else {
            print("Error creating input port: \(portStatus)")
            return
        }

        connectToAllSources()
    }

    // MARK: - Source Management

    func connectToAllSources() {
        let sourceCount = MIDIGetNumberOfSources()

        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            MIDIPortDisconnectSource(inputPort, source)
        }

        var names: [String] = []
        var anyConnected = false

        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)

            var deviceName: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(source, kMIDIPropertyName, &deviceName)
            let name = deviceName?.takeRetainedValue() as String? ?? "Unknown Device"

            let status = MIDIPortConnectSource(inputPort, source, nil)

            if status == noErr {
                names.append(name)
                anyConnected = true
            } else {
                print("Failed to connect to MIDI source: \(name), error: \(status)")
            }
        }

        onSourcesChanged?(names, anyConnected)
    }

    // MARK: - Event Handling

    private func handleEventList(_ eventListPtr: UnsafePointer<MIDIEventList>) {
        for packet in eventListPtr.unsafeSequence() {
            for word in MIDIEventPacket.WordCollection(packet) {
                guard word != 0 else { continue }

                let messageType = (word >> 28) & 0xF
                guard messageType == 0x2 else { continue }

                let status = UInt8((word >> 16) & 0xFF)
                let data1  = UInt8((word >> 8) & 0xFF)
                let data2  = UInt8(word & 0xFF)

                handleMIDIMessage([status, data1, data2])
            }
        }
    }

    func handleMIDIMessage(_ message: [UInt8]) {
        guard message.count >= 3 else { return }

        let status     = message[0] & 0xF0
        let controller = message[1]
        let value      = message[2]
        let note       = Int(controller)
        let velocity   = Int(value)

        switch status {
        case 0x90:
            if velocity > 0 {
                onNoteOn?(note, velocity)
            } else {
                onNoteOff?(note)
            }

        case 0x80:
            onNoteOff?(note)

        case 0xB0:
            handleControlChange(controller: controller, value: value)

        default:
            break
        }
    }

    private func handleControlChange(controller: UInt8, value: UInt8) {
        guard controller == 64 else { return } // Sustain pedal
        if value >= 64 {
            onSustain?(true)
        } else {
            onSustain?(false)
        }
    }

    deinit {
        MIDIClientDispose(midiClient)
    }
}
