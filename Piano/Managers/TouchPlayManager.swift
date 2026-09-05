import Foundation

@MainActor
class TouchPlayManager {
 
    private var task: Task<Void, Never>?
    private var output: Sampler?
    
    func setup(output: Sampler) {
        self.output = output
    }
    func startTask(_ notes: Set<Int>, rolled: Bool) {
        stopTask()
        if rolled {
            
            let sortedNotes = notes.sorted()

            task = Task {
                for note in sortedNotes {
                    guard !Task.isCancelled else { return }
                    output?.startNote(note)

                    try? await Task.sleep(for: .seconds(0.08))
                }
            }
        } else {
            task = Task {
                for note in notes {
                    output?.startNote(note)
                }
            }
        }
    }
    
    func stopTask() {
        task?.cancel()
        task = nil
        output?.stopAllNotes()
    }
}
