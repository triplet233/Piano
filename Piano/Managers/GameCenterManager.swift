import GameKit

enum GameCenterManager {
 
    @MainActor
    static func authenticatePlayer(completion: @escaping (Bool) -> Void) {
        
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
        
            if let viewController = viewController {
#if !os(macOS)
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    rootVC.present(viewController, animated: true)
                }
#else
                let vc = viewController as NSViewController
                let window = NSWindow(contentViewController: vc)
                window.makeKeyAndOrderFront(nil)
                
#endif
            } else if let error = error {
                completion(false)
                print("Game Center authentication error: \(error.localizedDescription)")
            } else {
                completion(GKLocalPlayer.local.isAuthenticated)
                print("Game Center authentication successful")
            }
        }
    }
    
    static func submitChallengeScore(difficulty: Difficulty, score: Int) async {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player not authenticated with Game Center")
            return
        }
        
        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [difficulty.leaderboardID]
            )
        } catch {
            print("Failed to submit score: \(error.localizedDescription)")
        }
    }
}
