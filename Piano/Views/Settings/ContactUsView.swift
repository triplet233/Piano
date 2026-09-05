import SwiftUI

struct ContactUsView: View {
    @Environment(\.openURL) private var openURL
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            HStack {
                Label("Send us an email", systemImage: "envelope")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                sendEmail(
                    to: "chordstudiocontact@gmail.com",
                    subject: "App Feedback",
                    body: ""
                )
            }
            .alert("Failed", isPresented: $showingAlert) {
                Button(role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
        .navigationTitle("Contact Us")
        .inlineNavigationTitle()

    }
    
    func sendEmail(to email: String, subject: String, body: String) {
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let emailURL = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") else {
            showAlert(message: "Failed to create email URL")
            return
        }
        
        openURL(emailURL) { accepted in
            if !accepted {
                showAlert(message: "Can't open email app.")
            }
        }
    }
    
    func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}
