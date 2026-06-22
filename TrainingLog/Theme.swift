import SwiftUI

extension Date {
    /// Midnight of this date in the current calendar — the canonical key for a day.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension Double {
    /// Renders a weight without trailing ".0" but keeps one decimal when needed.
    var lbString: String {
        self == rounded() ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}

/// A rounded "card" surface used throughout the app for a clean, native look.
private struct CardBackground: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View {
        modifier(CardBackground(padding: padding))
    }
}
