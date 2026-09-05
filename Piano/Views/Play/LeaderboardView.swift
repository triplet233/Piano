import SwiftUI
import GameKit

struct LeaderboardView: View {
    @State private var difficulty: Difficulty = .easy
    @State private var timeScope: GKLeaderboard.TimeScope = .allTime
    @State private var entries: [GKLeaderboard.Entry] = []
    @State private var localPlayerEntry: GKLeaderboard.Entry?
    @State private var isLoading = false

    let timeScopes: [GKLeaderboard.TimeScope] = [.today, .week, .allTime]

    var body: some View {
        VStack(spacing: 15) {
            Picker(selection: $difficulty, label: Label("Difficulty", systemImage: "target")) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Text(LocalizedStringKey(difficulty.name))
                }
            }
            .pickerStyle(.segmented)
            Picker(selection: $timeScope, label: Label("Time Scope", systemImage: "clock")) {
                ForEach(timeScopes, id: \.self) { scope in
                    switch scope {
                    case .today: Text("Today")
                    case .week: Text("This Week")
                    case .allTime: Text("All Time")
                    @unknown default: Text("Unknown")
                    }
                }
            }
            .pickerStyle(.segmented)
            
            ScrollView {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)
                } else {
                    LazyVStack {
                        ForEach(entries.sorted { $0.score > $1.score }, id: \.self) { entry in
                            LeaderboardEntryView(entry: entry)
                        }
                    }
                }
            }
            Divider()
            LeaderboardEntryView(entry: localPlayerEntry)
        }
        // ✅ Single .task(id:) replaces .task + two .onChange handlers
        // Automatically cancels & restarts when difficulty or timeScope changes
        .task(id: "\(difficulty.leaderboardID)-\(timeScope.rawValue)") {
            await loadLeaderboardData()
        }
        .padding()
        .background(.thinMaterial)
    }

    func loadLeaderboardData() async {
        isLoading = true          // ← show spinner immediately
        entries = []              // ← clear stale data right away
        localPlayerEntry = nil

        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [difficulty.leaderboardID])
            guard let leaderboard = leaderboards.first else { return }

            let (localEntry, fetchedEntries, _) = try await leaderboard.loadEntries(
                for: .global,
                timeScope: timeScope,
                range: NSRange(location: 1, length: 50)
            )

            await MainActor.run {
                self.entries = fetchedEntries
                self.localPlayerEntry = localEntry
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.entries = []
                self.localPlayerEntry = nil
                self.isLoading = false
            }
        }
    }
}

#Preview {
    LeaderboardView()
}
