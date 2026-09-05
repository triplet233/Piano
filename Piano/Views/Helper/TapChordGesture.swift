
import SwiftUI

struct TapChordGesture: Gesture {
    @Binding var isPressed: Bool
    let notes: Set<Int>
    let touchPlay: TouchPlayManager?
    
    @AppStorage("rolled") private var rolled: Bool = false
    
    var body: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !isPressed else { return }
                
                touchPlay?.startTask(notes, rolled: rolled)
                isPressed = true
            }
            .onEnded { _ in
                touchPlay?.stopTask()
                isPressed = false
            }
    }
}
