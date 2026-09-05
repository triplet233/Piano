import SwiftUI
import GameKit

struct LeaderboardEntryView: View {
    
    let entry: GKLeaderboard.Entry?
    
    @State private var playerImage: Image? = nil
    
    var body: some View {
        Group {
            if let entry, entry.rank > 0 {
                HStack(spacing: 24) {
                    Text("\(entry.rank)")
                    
                    HStack {
                        // Profile image
                        if let playerImage {
                            playerImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 24, height: 24)
                        }
                        
                        
                        Text(entry.player.displayName)
                    }
                    Spacer()
                    Text(entry.formattedScore)
                }
                .onAppear {
                    loadPlayerImage(for: entry.player)
                }
            } else {
                Text("You don't have a score yet.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .cornerRadius(16)
    }
    
    private func loadPlayerImage(for player: GKPlayer) {
        player.loadPhoto(for: .small) { image, error in
            if let platformImage = image {
                Task { @MainActor in
                    playerImage = Image(platformImage: platformImage)
                }
            }
        }
    }
}
