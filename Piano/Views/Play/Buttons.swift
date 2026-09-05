import SwiftUI

struct SustainButton: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Image(systemName: isOn ? "circle.fill" : "circle")
                .foregroundStyle(isOn ? Color.accentColor : .secondary)
        }
        .buttonStyle(.bordered)
        .help("Sustain")
    }
}

struct MetronomeButton: View {
    
    @State private var isOn: Bool = false
    
    @Environment(\.audio) private var audio
    @AppStorage("metronomeBPM") var metronomeBPM: Double = 90
    
    var body: some View {
        Button {
            if isOn {
                audio.metronome.stopTask()
            } else {
                audio.metronome.startTask(tempo: metronomeBPM)
            }
            isOn.toggle()
        } label: {
            Image(systemName: isOn ? "metronome.fill" : "metronome")
                .foregroundStyle(isOn ? Color.accentColor : .secondary)
        }
        .keyboardShortcut(.space, modifiers: [])
        .buttonStyle(.bordered)
        .help("Metronome")
        .contextMenu {
            Picker("Tempo", selection: $metronomeBPM) {
                ForEach(Constants.bpmRange, id: \.self) { bpm in
                    Text("\(bpm)")
                        .tag(Double(bpm))
                }
            }
        }
    }
}
