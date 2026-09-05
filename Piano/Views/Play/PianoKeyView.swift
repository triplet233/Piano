import SwiftUI

struct PianoKeyView: View {
    
    let vpiano: VirtualPianoManager
    let midiNote: Int
    var keyHeight: CGFloat
    var keyWidth: CGFloat
    
    @State private var isBeingPressed = false
    
    var isBlackKey: Bool {
        [1, 3, 6, 8, 10].contains(midiNote % 12)
    }

    var isPressed: Bool {
        vpiano.highlightedMidiNotes.contains(midiNote)
    }
    
    private var keyColor: Color {
        if isPressed {
            isBlackKey ? Color.accentColor.mix(with: .white, by: 0.5) : Color.accentColor.mix(with: .white, by: 0.7)
        } else {
            isBlackKey ? .black : .white.mix(with: .gray, by: 0.05)
        }
    }
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 3)
           .fill(keyColor)
           .overlay {
               RoundedRectangle(cornerRadius: 3)
                   .stroke(Color.black, lineWidth: 0.6)
           }
           .overlay(alignment: .bottom) {
               if midiNote % 12 == 0 {
                   Text("C\(midiNote / 12 - 1)")
                       .padding(.bottom, keyHeight * 0.03)
                       .font(.caption)
                       .foregroundStyle(Color.black.opacity(0.6))
               }
               
           }
           .frame(width: keyWidth, height: keyHeight)
           .scaleEffect(x: 1.0, y: isPressed ? 0.95 : 1.0)
           .animation(.easeInOut(duration: 0.1), value: isPressed)
           .zIndex(isBlackKey ? 1 : 0)
           .shadow(color: isBlackKey ? .black.opacity(0.6) : .black.opacity(0.3), radius: 2)
#if os(macOS)
           .simultaneousGesture(
               DragGesture(minimumDistance: 0)
                   .onChanged { _ in
                       guard !isBeingPressed else { return }
                       isBeingPressed = true
                           
                       vpiano.touchDown(on: midiNote)
                   }
                   .onEnded { _ in
                       vpiano.touchUp(on: midiNote)
                       isBeingPressed = false
                   }
           )
#elseif os(iOS)
           .gesture(
               PianoKeyGestureRecognizer(
                   onBegan: {
                       guard !isBeingPressed else { return }
                       isBeingPressed = true
                       
                       vpiano.touchDown(on: midiNote)
                   },
                   onEnded: {
                       vpiano.touchUp(on: midiNote)
                       
                       isBeingPressed = false
                   }
               )
           )
#endif
    }

}

#if os(iOS)

import UIKit

class ImmediateTouchGestureRecognizer: UIGestureRecognizer {
    var onBegan: (() -> Void)?
    var onEnded: (() -> Void)?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
        onBegan?()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
        onEnded?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
        onEnded?()
    }
}

struct PianoKeyGestureRecognizer: UIGestureRecognizerRepresentable {
    var onBegan: () -> Void
    var onEnded: () -> Void

    func makeUIGestureRecognizer(context: Context) -> ImmediateTouchGestureRecognizer {
        let r = ImmediateTouchGestureRecognizer()
        r.onBegan = context.coordinator.handleBegan
        r.onEnded = context.coordinator.handleEnded
        r.delegate = context.coordinator
        r.cancelsTouchesInView = false
        r.delaysTouchesBegan = false
        r.delaysTouchesEnded = false
        return r
    }

    func handleUIGestureRecognizerAction(_ recognizer: ImmediateTouchGestureRecognizer, context: Context) {}

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator(onBegan: onBegan, onEnded: onEnded)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onBegan: () -> Void
        var onEnded: () -> Void

        init(onBegan: @escaping () -> Void, onEnded: @escaping () -> Void) {
            self.onBegan = onBegan
            self.onEnded = onEnded
        }

        func handleBegan() { onBegan() }
        func handleEnded() { onEnded() }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool { true }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRequireFailureOf other: UIGestureRecognizer
        ) -> Bool { false }
    }
}

#endif
