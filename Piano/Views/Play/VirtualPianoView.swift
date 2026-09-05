
import SwiftUI
import Observation

struct VirtualPianoView: View {
    
    let vpiano: VirtualPianoManager
    
    let whiteKeyHeight: CGFloat
    let whiteKeyWidth: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                ForEach(21..<109, id: \.self) { midiNote in
                    if [0, 2, 4, 5, 7, 9, 11, 12].contains(midiNote % 12) {
                        PianoKeyView(vpiano: vpiano, midiNote: midiNote, keyHeight: whiteKeyHeight, keyWidth: whiteKeyWidth)
                            .id(midiNote)
                    }
                }
            }
            HStack(alignment: .top, spacing: 0) {
                Spacer().frame(width: whiteKeyWidth * 0.85)
                ForEach(21..<109, id: \.self) { midiNote in
                    if [1, 3, 6, 8, 10].contains(midiNote % 12) {
                        let leadingSpace = [3, 10].contains(midiNote % 12) ? whiteKeyWidth * 1.06 : whiteKeyWidth * 0.51
                        PianoKeyView(vpiano: vpiano, midiNote: midiNote, keyHeight: whiteKeyHeight * 0.625, keyWidth: whiteKeyWidth * 0.67)
                            .padding(.trailing, leadingSpace)
                            .id(midiNote)
                    }
                }
            }
        }
    }
}


#Preview {
    
    ScrollView(.horizontal) {
//        VirtualPianoView()
    }
    
}
