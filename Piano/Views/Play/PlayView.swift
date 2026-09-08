import SwiftUI

struct PlayView: View {
    
    enum Screen: Equatable {
        case keyboardAndChord, chord, learn, challenge

        var icon: String {
            switch self {
            case .keyboardAndChord: "music.note.list"
            case .chord: "music.note.tv"
            case .learn: "text.book.closed"
            case .challenge: "trophy.fill"
            }
        }
        var title: LocalizedStringKey {
            switch self {
            case .keyboardAndChord: "Keyboard"
            case .chord: "Monitor"
            case .learn: "Dictionary"
            case .challenge: "Challenge"
            }
        }
    }
    @State private var vpiano = VirtualPianoManager()
    @State private var challenge = ChallengeManager()
    
    @State private var showSettingsSheet: Bool = false
    @State private var showSubscriptionSheet: Bool = false
    @State private var showChallengeSheet: Bool = false
    @State private var selectedScreen: Screen = .keyboardAndChord
    
    @Environment(MIDIManager.self) private var midi
    @Environment(\.audio) private var audio
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {

        GeometryReader { geometry in
            let size = geometry.size
            let viewHeight = size.height
            let viewWidth = size.width
            
            let keyboardHeight = {
                if [.learn, .chord].contains(selectedScreen) {
                    min(max(150, viewHeight * 0.3), 400)
                } else if horizontalSizeClass == .compact || platform == "macOS" {
                    min(max(250, viewHeight * 0.8), 400)
                } else {
                    min(max(250, viewHeight * 0.8), 600)
                }
            }()
            let keyboardWidth = {
                switch selectedScreen {
                case .chord: CGFloat(30)
                case .learn:
                    min(max(30, viewWidth * 0.035), 40)
                default:
                    min(max(60, viewWidth * 0.055), 68)
                }
            }()
            
            VStack {
    
                if selectedScreen == .challenge {
                    ChallengeView(challenge: challenge, sustainButton: SustainButton(isOn: $vpiano.keepNote)) {
                        selectedScreen = .keyboardAndChord
                    }
                    .onChange(of: vpiano.highlightedMidiNotes) { _, newValue in
                        challenge.notesPlayed = newValue
                    }
                } else if [.chord, .keyboardAndChord].contains(selectedScreen) {
                    ChordRecognizerView(vpiano: vpiano, isLarge: selectedScreen == .chord, sustainButton: SustainButton(isOn: $vpiano.keepNote))
                }
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VirtualPianoView(vpiano: vpiano, whiteKeyHeight: keyboardHeight, whiteKeyWidth: keyboardWidth)
                            
                            .task { @MainActor in
                                proxy.scrollTo(59, anchor: .center)
                            }
                            .onChange(of: selectedScreen) { @MainActor in
                                proxy.scrollTo(59, anchor: .center)
                            }
                            .allowsHitTesting(selectedScreen != .learn)
                            
                    }
                }
            }
        }
        .task {
            vpiano.start(midi: midi, output: audio.sampler)
        }
        .onChange(of: selectedScreen) { _, new in
            audio.sampler.stopAllNotes()
            vpiano.highlightedMidiNotes.removeAll()
            
            if [.learn, .challenge].contains(new) {
                audio.metronome.stopTask()
            }
            preventScreenDimming(isEnabled: new == .chord ? true : false)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if selectedScreen == .keyboardAndChord, newPhase == .background {
                audio.sampler.stopAllNotes()
            }
        }
        .onDisappear {
            audio.sampler.stopAllNotes()
            audio.metronome.stopTask()
            preventScreenDimming(isEnabled: false)
        }
        .sheet(isPresented: $showChallengeSheet) {
            NavigationStack {
                ChallengePanelView { difficulty, isPractice in
                    selectedScreen = .challenge
                    Task {
                        try? await Task.sleep(for: .seconds(0.4))
                        if isPractice {
                            challenge.startPractice(difficulty: difficulty)
                        } else {
                            challenge.startChallengeTimer(difficulty: difficulty)
                        }
                    }
                }
                .minSizeRestrictionIfMacOS()
                .presentationDetentsMedium()
            }
        }
        .safeAreaInset(edge: .bottom) {
            if selectedScreen == .learn {
                LearnView(vpiano: vpiano)
                    .transition(.move(edge: .bottom))
            }
        }
        .subscriptionSheet(isPresented: $showSubscriptionSheet)
        .sheet(isPresented: $showSettingsSheet) {
            NavigationStack {
                SettingsView()
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    if selectedScreen == .chord {
                        selectedScreen = .keyboardAndChord
                    } else {
                        selectedScreen = .chord
                    }
                } label: {
                    if selectedScreen == .chord {
                        Image(systemName: Screen.keyboardAndChord.icon)
                    } else {
                        Image(systemName: Screen.chord.icon)
                        
                    }
                }
                .help(selectedScreen == .chord ?
                      String(localized: "Play") : String(localized: "Chord Monitor")
                )
                
                Button {
                    if selectedScreen == .learn {
                        selectedScreen = .keyboardAndChord
                    } else {
                        selectedScreen = .learn
                    }

                } label: {
                    if selectedScreen == .learn {
                        Image(systemName: Screen.keyboardAndChord.icon)
                    } else {
                        Image(systemName: Screen.learn.icon)
                        
                    }
                }
                .help(selectedScreen == .learn ?
                      String(localized: "Play") : String(localized: "Chord Dictionary")
                )
                
                Button {
                    if selectedScreen == .challenge {
                        selectedScreen = .keyboardAndChord
                    } else {
                        showChallengeSheet.toggle()
                    }
                } label: {
                    Image(systemName: selectedScreen == .challenge ? Screen.challenge.icon : "trophy")
                }
                .help("Challenge")
            
                
                Button {
                    showSettingsSheet.toggle()
                } label: {
                    Image(systemName: "gearshape")
                }
                .help("Settings")
            }
        }
 
        .ignoresSafeArea(.container, edges: [.bottom])
        .background(Color.secondary.opacity(0.1))
        .iOSDefersSystemGesturesOnBottom(shouldDefer: selectedScreen == .keyboardAndChord)
        .navigationTitle(Text(selectedScreen.title))
        .inlineNavigationTitle()
    }
}

#Preview {
    @Previewable let audio = AudioManager()
    @Previewable @State var midi = MIDIManager()
    NavigationStack {
        PlayView()
            .environment(\.audio, audio)
            .environment(midi)
    }
}
