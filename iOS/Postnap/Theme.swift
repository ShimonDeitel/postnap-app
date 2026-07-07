import SwiftUI

/// Bespoke palette for Postnap - Grogginess Log — sage green.
enum Theme {
    static let accent = Color(red: 0.45, green: 0.65, blue: 0.35)
    static let background = Color(red: 0.05, green: 0.07, blue: 0.05)
    static let cardBackground = Color(red: 0.1, green: 0.12000000000000001, blue: 0.1)
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.55)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static var cardCornerRadius: CGFloat { 16 }
}
