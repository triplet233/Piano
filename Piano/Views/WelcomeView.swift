import SwiftUI

struct WelcomeView: View {
    
    @Environment(\.verticalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        VStack {
            let layout = sizeClass == .compact
                ? AnyLayout(HStackLayout(spacing: 20))
                : AnyLayout(VStackLayout(spacing: 20))
            
            layout {
                Text("👋")
                    .font(.system(size: 50))
                
                Text("Welcome to the Piano App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()
            
            
            List {
                FeatureRowView(icon: "pianokeys", title: String(localized: "Realistic Piano Sound"))
                FeatureRowView(icon: "scope", title: String(localized: "Real-Time Chord Recognition"))
                FeatureRowView(icon: "text.book.closed", title: String(localized: "Chord Dictionary"))
                FeatureRowView(icon: "powerplug", title: String(localized: "MIDI Support"))
                FeatureRowView(icon: "trophy", title: String(localized: "Challenge Mode"))
                FeatureRowView(icon: "guitars", title: String(localized: "A Variety of Instruments"))
            }
            .scrollContentBackground(.hidden)
            
            Button {
                dismiss()
            } label: {
                Text("Get Started")
                    .padding(10)
                    .font(.headline)
            }
            .buttonStyle(.glassProminent)
            .padding()
        }
        .minSizeRestrictionIfMacOS()
        .toolbarCloseButton(dismiss: dismiss)
    }
}




#Preview {
    WelcomeView()
}
