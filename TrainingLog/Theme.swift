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

extension Color {
    /// Dot + accent for strength workouts (the app's orange accent).
    static var strengthAccent: Color { .accentColor }
    /// Dot + accent for finger-training days — teal, the complement of the orange
    /// accent, so the two calendar dots stay easy to tell apart.
    static var fingerAccent: Color { .teal }
}

/// A rounded "card" surface used throughout the app for a clean, native look.
private struct CardBackground: ViewModifier {
    var horizontal: CGFloat = 16
    var vertical: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

extension View {
    /// A card with uniform padding on all sides.
    func card(padding: CGFloat = 16) -> some View {
        modifier(CardBackground(horizontal: padding, vertical: padding))
    }

    /// A card with independent horizontal and vertical padding — for list rows that want
    /// a tighter vertical footprint without losing horizontal breathing room.
    func card(horizontal: CGFloat, vertical: CGFloat) -> some View {
        modifier(CardBackground(horizontal: horizontal, vertical: vertical))
    }
}
