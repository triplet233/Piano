import SwiftUI


struct SettingsView: View {
    
    @AppStorage("instrument") var instrument: String = "grand"
    @AppStorage("keyboardVelocity") var keyboardVelocity: Double = 0.7
    @AppStorage("rolledChord") var rolledChord: Bool = false
    @AppStorage("identifyMultipleChords") var identifyMultipleChords: Bool = false
    @AppStorage("metronomeBPM") var metronomeBPM: Double = 90
    @AppStorage("playModeKey") var playModeKey: String = "C"
    @AppStorage("keyboardGain") var keyboardGain: Double = 0.0
    @AppStorage("metronomeGain") var metronomeGain: Double = 0.0
    
    @AppStorage("composer") var composerName: String = ""
    @AppStorage("defaultSongBPM") var defaultSongBPM: Int = 80
    @AppStorage("defaultSongKey") var defaultSongKey: String = "C"
    @AppStorage("defaultEditMode") var defaultEditMode: String = "picker"
    
    @AppStorage("colorScheme") var appColorScheme: String = "System"
    @AppStorage("accentColor") var accentColor: String = "Default"
    
    @State private var showSubscriptionSheet: Bool = false
    
    @Environment(\.appState) private var appState
    @Environment(\.audio) private var audio
    @Environment(MIDIManager.self) private var midi
    @Environment(SubscriptionManager.self) private var subscription
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        Form {
            Section {
                
                Picker(selection: $instrument) {
                    ForEach(Instrument.allCases, id: \.self) { instrument in
                        Text(LocalizedStringKey(instrument.description))
                            .subscriptionIcon(show: instrument.subscriptionRequired)
                            .tag(instrument.rawValue)
                    }
                } label: {
                    Label("Instrument", systemImage: "pianokeys")
                }
                .onSubscriptionGatedChange($showSubscriptionSheet, of: $instrument) {
                    Instrument(rawValue: $0)!.subscriptionRequired
                } onAccepted: { newValue in
                    audio.sampler.loadInstrument(Instrument(rawValue: newValue)!)
                }
                
                Picker(selection: $metronomeBPM) {
                    ForEach(Constants.bpmRange, id: \.self) { num in
                        Text(num.description)
                            .tag(Double(num))
                    }
                } label: {
                    Label("Tempo", systemImage: "metronome")
                }
                
                Picker(selection: $playModeKey) {
                    ForEach(PitchClass.allCases, id: \.self) { key in
                        Text(key.description)
                            .subscriptionIcon(show: key != .C)
                            .tag(key.rawValue)
                    }
                } label: {
                    Label("Key", systemImage: "music.note")
                }
                .onSubscriptionGatedChange($showSubscriptionSheet, of: $playModeKey) {
                    $0 != PitchClass.C.rawValue
                } onAccepted: { newValue in
                    appState.setPlayModeKey(newValue)
                }
                
                Toggle(isOn: $rolledChord) {
                    Label("Rolled Chord", systemImage: "music.quarternote.3")
                        .subscriptionIcon(show: true)
                }
                .onSubscriptionGatedChange($showSubscriptionSheet, of: $rolledChord) {
                    $0 == true
                }
                
                Toggle(isOn: $identifyMultipleChords) {
                    Label("Identify Multiple Chords", systemImage: "circle.grid.2x2")
                        .subscriptionIcon(show: true)
                }
                .onSubscriptionGatedChange($showSubscriptionSheet, of: $identifyMultipleChords) {
                    $0 == true
                } onAccepted: { newValue in
                    appState.setIdentifyMultipleChords(newValue)
                }
                
                VolumeView(label: Text("Keyboard"), range: -12...6, volume: $keyboardGain)
                    .frame(minHeight: 12)
                .onChange(of: keyboardGain) { _, newValue in
                    audio.sampler.setGain(Float(newValue))
                }

                VolumeView(label: Text("Metronome"), range: -12...6, volume: $metronomeGain)
                    .frame(minHeight: 12)
                .onChange(of: metronomeGain) { _, newValue in
                    audio.metronome.setGain(Float(newValue))
                }
                
            }
            
            Section("App") {
                Picker(selection: $appColorScheme) {
                    ForEach(["System", "Light", "Dark"], id: \.self) { option in
                        Text(LocalizedStringKey(option))
                    }
                } label: {
                    Label("Appearance", systemImage: "circle.lefthalf.filled")
                }
                
                Picker(selection: $accentColor) {
                    ForEach(["Default"] + availableAccentColors.keys.filter { $0 != "Default" }.sorted(), id: \.self) { option in
                        Text(LocalizedStringKey(option))
                            .subscriptionIcon(show: !["Default", "Blue"].contains(option))
                    }
                } label: {
                    Label("Theme Color", systemImage: "paintpalette")
                }
                .onSubscriptionGatedChange($showSubscriptionSheet, of: $accentColor) {
                    !["Default", "Blue"].contains($0)
                }

                NavigationLink(destination: MIDISourcesView(midi: midi)) {
                    HStack {
                        Label("MIDI Sources", systemImage: "powerplug")
                        Spacer()
                        Text("\(midi.sourceList.count)")
                    }
                }
            }
            Section("Upgrade") {
                if subscription.isSubscribed {
                    Text("Piano Pro is active.")
                } else {
                    Button {
                        showSubscriptionSheet.toggle()
                    } label: {
                        Label("Upgrade to Pro", systemImage: "crown")
                    }
                }
                Button("Restore Purchases") {
                    Task {
                        await subscription.restorePurchases()
                    }
                }
            }
            
            Section("Info")  {
                NavigationLink(destination: ContactUsView()) {
                    Label("Contact Us", systemImage: "envelope")
                }
                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info.circle")
                }
                
                HStack {
                    Label("Version", systemImage: "hammer")
                    Spacer()
                    Text("\(Bundle.main.appVersion) (\(Bundle.main.appBuild))")
                        .foregroundStyle(.secondary)
                }
            }
            
//            if let url = URL(string: "https://apps.apple.com/us/app/chord-studio/id6749439732") {
//                ShareLink(item: url) {
//                    Label("Share App", systemImage: "heart")
//                }
//            }
        }
        .subscriptionSheet(isPresented: $showSubscriptionSheet)
        .toolbarCloseButton(dismiss: dismiss)
        .navigationTitle("Settings")
        .inlineNavigationTitle()
        
    }
}

let availableAccentColors: [String: Color?] = [
    "Default": nil,
    "Blue": .blue,
    "Red": .red,
    "Green": .green.mix(with: .white, by: 0.1),
    "Orange": .orange.mix(with: .white, by: 0.1),
    "Yellow": .yellow,
    "Pink": .pink.mix(with: .white, by: 0.2),
    "Purple": .purple.mix(with: .white, by: 0.1),
    "Brown": .brown,
    "Cyan": .cyan
]

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }

    var appBuild: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "-"
    }
}


#Preview  {
    @Previewable let audio = AudioManager()
    @Previewable @State var midi = MIDIManager()
    @Previewable @State var subscription = SubscriptionManager()
    
    SettingsView()
        
        .environment(\.audio, audio)
        .environment(midi)
        .environment(subscription)
}

