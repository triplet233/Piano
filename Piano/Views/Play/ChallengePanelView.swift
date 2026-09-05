import SwiftUI

extension Difficulty {
    var color: Color {
        switch self {
        case .easy: .green
        case .medium: .orange
        case .hard: .red
        case .impossible: .primary
        }
    }
}

struct ChallengePanelView: View {
    
    let onChallengeStarted: (Difficulty, Bool) -> Void
    
    @State private var isLoggedIn: Bool = false
    @State private var selectedDifficulty: Difficulty? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var selected: Bool {
        selectedDifficulty != nil
    }
    
    var impossibleSelectedColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    let isSelected = selectedDifficulty == difficulty
                    
                    
                    Text(LocalizedStringKey(difficulty.name))
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundColor(
                        isSelected ?
                        (selectedDifficulty == .impossible ? impossibleSelectedColor : .black) :
                        difficulty.color
                    )
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? difficulty.color : difficulty.color.opacity(0.08))
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedDifficulty = difficulty
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Button {
                    guard let selectedDifficulty else { return }
                    dismiss()
                    onChallengeStarted(selectedDifficulty, true)
                        
                } label: {
                    Text("Practice")
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)

                }
                .buttonStyle(.glass)
                
                Button {
                    guard let selectedDifficulty else { return }
                    
                    dismiss()
                    onChallengeStarted(selectedDifficulty, false)
                    
                } label: {
                    Text("Start")
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
            }
            .bold()
            .disabled(!selected)
        }
        .task {
            GameCenterManager.authenticatePlayer() { success in
                isLoggedIn = success
            }
        }
        .toolbarCloseButton(dismiss: dismiss)
        .toolbar {
            NavigationLink(destination: LeaderboardView()) {
                Image(systemName: "chart.bar.xaxis")
            }
            .disabled(!isLoggedIn)
        }
        .background {
            Color.clear
                .contentShape(Rectangle()) // Makes the whole background tappable
                .onTapGesture {
                    withAnimation { selectedDifficulty = nil }
                }
        }
        .padding()
        .navigationTitle("Challenge")
        .inlineNavigationTitle()
    }
}

#Preview {
    NavigationStack {
        ChallengePanelView { _, _ in }
    }
}
