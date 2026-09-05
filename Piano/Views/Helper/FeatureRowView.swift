import SwiftUI

struct FeatureRowView<Content: View>: View {
    let icon: String
    let title: String
    let content: Content?

    init(icon: String, title: String, @ViewBuilder content: () -> Content? = { nil }) {
        self.icon = icon
        self.title = title
        self.content = content()
    }
    init(icon: String, title: String) where Content == EmptyView {
        self.icon = icon
        self.title = title
        self.content = nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 24)

                Text(title)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()
            }

            // Optional detail content
            if let content = content {
                VStack(alignment: .leading) {
                    content
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    FeatureRowView(icon: "star", title: "asfsadfs")
}
