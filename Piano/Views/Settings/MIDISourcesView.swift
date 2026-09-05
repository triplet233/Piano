import SwiftUI

struct MIDISourcesView: View {
    let midi: MIDIManager
    
    var sourceList : [String] {
        midi.sourceList
    }
    var body: some View {
        List {
            if sourceList.isEmpty {
                Text("No MIDI Sources Found (Currently, only USB MIDI devices are supported).")
                    .foregroundStyle(.secondary)
            }
            ForEach(sourceList, id: \.self) { source in
                Text(source)
            }
        }
        .navigationTitle("MIDI Sources")
        .inlineNavigationTitle()
    }
}
