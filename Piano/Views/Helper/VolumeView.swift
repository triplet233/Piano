import SwiftUI

struct VolumeView<Label: View, T: BinaryFloatingPoint & Comparable>: View {
    let label: Label
    let range: ClosedRange<T>
    @Binding var volume: T

    var body: some View {
        GeometryReader { geometry in
            HStack {
                label
                    .padding(.trailing)
                Spacer()
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Slider(
                        value: Binding<Double>(
                            get: { Double(volume) },
                            set: { volume = T($0) }
                        ),
                        in: Double(range.lowerBound)...Double(range.upperBound)
                    )

                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .frame(maxWidth: geometry.size.width / 3 * 2)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}


#Preview {
    Form {
        Section {
            VolumeView(label: Text("Volume"), range: -6...6, volume: .constant(0.0))
        }
    }
}
