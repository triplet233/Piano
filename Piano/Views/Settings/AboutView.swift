import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {

                HStack {
                    Link("Soundfont", destination: URL(string: "https://musical-artifacts.com/artifacts/1176")!)
                }

                HStack {
                    Link("Privacy Policy", destination: URL(string: "https://chordstudio3572.wordpress.com")!)
                    
                }
                HStack {
                    Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                }
            }
        }
        .navigationTitle("About")
        .inlineNavigationTitle()
    }
}

#Preview {
    AboutView()
}
