import SwiftUI
import SwiftData

struct ContentView: View {
    
    @AppStorage("hasSeenWelcome") var hasSeenWelcome: Bool = false
    @AppStorage("lastUsedVersion") var lastUsedVersion: String = "0"

    @State var path = NavigationPath()

    @State var showWelcome: Bool = false
    @State var showWhatsNew: Bool = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            PlayView()
        }
        .onAppear {
            lastUsedVersion = Bundle.main.appVersion
            if !hasSeenWelcome {
                showWelcome = true
                hasSeenWelcome = true
            }
        }
        .sheet(isPresented: $showWelcome){
            NavigationStack {
                WelcomeView()
            }
        }
    }
}



#Preview {
    @Previewable let audio = AudioManager()
    @Previewable @State var appState = AppStateManager()
    @Previewable @State var midi = MIDIManager()
    @Previewable @State var touchPlay = TouchPlayManager()
    @Previewable @State var subscription = SubscriptionManager()
    
    ContentView()
        .environment(\.audio, audio)
        .environment(\.touchPlay, touchPlay)
        .environment(\.appState, appState)
        .environment(midi)
        .environment(subscription)
//        .environment(\.locale, Locale(identifier: "zh-Hans"))
}
