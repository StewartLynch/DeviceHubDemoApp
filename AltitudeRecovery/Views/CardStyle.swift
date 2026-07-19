import SwiftUI

private struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

