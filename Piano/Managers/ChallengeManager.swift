import Observation

@MainActor
@Observable
class ChallengeManager {
    enum Phase {
        case idle, countDown, started, finished, practice
    }
    
    var phase: Phase = .idle
    var currentChord: Chord? = nil
    var validating: Bool = false
    var score: Int = 0
    var countDownTimeLeft = 0
    var timeLeft: Double = 0

    var notesPlayed: Set<Int> = [] {
        didSet {
            guard [.started, .practice].contains(phase) else { return }

            Task {
                if await validateChord() {
                    score += 1
                    generateNewChord()
                }
            }
        }
    }

    private var difficulty: Difficulty? = nil
    
    func startPractice(difficulty: Difficulty) {
        self.difficulty = difficulty
        phase = .practice
        generateNewChord()
    }
    func startChallengeTimer(difficulty: Difficulty) {
        self.difficulty = difficulty
        phase = .countDown
        countDownTimeLeft = 4
        score = 0
        Task {
            for await _ in timerStream(interval: 1.0) {
                if phase == .countDown, countDownTimeLeft > 1 {
                    countDownTimeLeft -= 1
                } else {
                    break
                }
            }
            
            timeLeft = 60.0
            phase = .started
            generateNewChord()
            
            for await _ in timerStream(interval: 0.01) {
                if phase == .started, timeLeft > 0 {
                    timeLeft -= 0.01
                    timeLeft = max(timeLeft, 0) // Clamp to 0
                } else {
                    break
                }
            }
            if timeLeft <= 0, countDownTimeLeft == 1 {
                phase = .finished
                currentChord = nil
                
                await GameCenterManager.submitChallengeScore(difficulty: difficulty, score: score)
                
            }
        }
    }
    
    func retry() {
        guard let difficulty else { return }
        
        startChallengeTimer(difficulty: difficulty)
    }
    
    private func validateChord() async -> Bool {
        guard let chord = currentChord, chord.validate(midiNotes: notesPlayed) else { return false }
        
        defer { validating = false }
        validating = true
        
        try? await Task.sleep(for: .seconds(0.25))

        guard validating, chord.validate(midiNotes: notesPlayed) else { return false }
        
        return true
    }
    
    private func generateNewChord() {
        guard let difficulty else { return }
        
        var newChord = difficulty.generateRandomChord()
        while newChord == currentChord {
            newChord = difficulty.generateRandomChord()
        }
        currentChord = newChord
    }
}
