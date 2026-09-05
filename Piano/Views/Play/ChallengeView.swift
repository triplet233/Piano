import SwiftUI

struct ChallengeView: View {
    
    let challenge: ChallengeManager
    let sustainButton: SustainButton
    let onExit: () -> Void
    
    var content: String {
        switch challenge.phase {
        case .countDown: "\(challenge.countDownTimeLeft)"
        case .started, .practice:
            if let currentChord = challenge.currentChord {
                currentChord.description
            } else {
                ""
            }
        case .finished: "\(challenge.score)"
        default: ""
        }
    }
    
    var foregroundStyleActive: Bool {
        switch challenge.phase {
        case .started, .practice: challenge.validating
        default: true
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                VStack {
                    Text(content)
                        .font(.largeTitle)
                        .foregroundStyle(foregroundStyleActive ? Color.accentColor : .secondary)
                    
                }
                .monospaced()
                
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    switch challenge.phase {
                    case .started:
                        Text("\(challenge.score)")
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                        Text(String(format: "%.2f", challenge.timeLeft))
                            .foregroundStyle(.secondary)
                        
                        sustainButton
                        
                    case .finished:
                        Button(role: .confirm) {
                            onExit()
                        }
                        Spacer()
                        Button("Retry") {
                            challenge.retry()
                        }
                    case .practice:
                        Button(role: .confirm) {
                            onExit()
                        }
                        Spacer()
                        sustainButton
                    default: Spacer()
                    }
                
                }
                .monospaced()
                .padding()
            }
        }
        .onAppear {
            challenge.phase = .idle
        }
    }
}

#Preview {
//    ChallengeView(vpiano: .init())
}


