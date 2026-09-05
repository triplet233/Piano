import SwiftUI
import SwiftData

@main
struct Chord_MasterApp: App {
    
    private let audio = AudioManager()
    @State private var appState = AppStateManager()
    @State private var midi = MIDIManager()
    @State private var touchPlay = TouchPlayManager()
    @State private var subscription = SubscriptionManager()
    
    
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("accentColor") private var accentColor: String = "Default"
    @AppStorage("colorScheme") private var appColorScheme: String = "System"
    
    init() {
        UserDefaults.standard.register(defaults: defaultSettings)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    midi.setUpEngine(output: audio.sampler)
                    touchPlay.setup(output: audio.sampler)
                    
                    await subscription.updateSubscriptionStatus()
                    await subscription.startTransactionListener()
                }
                .preferredColorScheme(getColorScheme())
                .tint(availableAccentColors[accentColor]!)
        }
        .environment(\.audio, audio)
        .environment(\.touchPlay, touchPlay)
        .environment(\.appState, appState)
        .environment(midi)
        .environment(subscription)
        
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
#if !os(macOS)
                Task {
                    try? await Task.sleep(for: .seconds(0.5))
                    audio.startAudioSession()
                    audio.startAudioEngine()
                }
#endif
            default:
                break
            }
        }
        
        
#if os(macOS)
         Settings {
             SettingsView()
         }
#endif
    }
    
    private func getColorScheme() -> ColorScheme? {
        switch appColorScheme {
        case "Light": .light
        case "Dark": .dark
        default: nil
        }
    }
}


extension EnvironmentValues {
    @Entry var audio = AudioManager()
    @Entry var touchPlay: TouchPlayManager?
    @Entry var appState = AppStateManager()
}

#if os(iOS)
import UIKit
#endif

@MainActor
func preventScreenDimming(isEnabled: Bool) {
    #if os(iOS)
    UIApplication.shared.isIdleTimerDisabled = isEnabled
    #endif
}




