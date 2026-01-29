import SwiftUI

// MARK: - Colors

extension Color {
    // Primary palette - soft, sophisticated blues
    static let spotterPrimary = Color(hex: "64748B")        // Slate-500: muted blue-gray
    static let spotterPrimaryHover = Color(hex: "475569")   // Slate-600: pressed states

    // Backgrounds - clean, minimal
    static let spotterBackground = Color(hex: "FAFAFA")     // Near-white
    static let spotterSurface = Color(hex: "F1F5F9")        // Slate-100: subtle cards (use sparingly)

    // Text - readable, not harsh
    static let spotterText = Color(hex: "1E293B")           // Slate-800: primary text
    static let spotterTextSecondary = Color(hex: "64748B")  // Slate-500: muted text

    // Borders - light definition
    static let spotterBorder = Color(hex: "E2E8F0")         // Slate-200: subtle dividers

    // Accents - muted, not alarming
    static let spotterSuccess = Color(hex: "059669")        // Emerald-600
    static let spotterWarning = Color(hex: "D97706")        // Amber-600

    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fonts

extension Font {
    // Typography - clean, refined hierarchy
    static let spotterTitle = Font.system(.title, design: .default, weight: .semibold)
    static let spotterHeadline = Font.system(.headline, design: .default, weight: .medium)
    static let spotterBody = Font.system(.body, design: .default, weight: .regular)
    static let spotterCaption = Font.system(.caption, design: .default, weight: .regular)
    static let spotterLabel = Font.system(.subheadline, design: .default, weight: .medium)

    // Large numbers - prominent but not bubbly
    static let spotterLargeNumber = Font.system(size: 48, weight: .medium, design: .default)
}

// MARK: - Spacing

enum Spacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 12
    static let md: CGFloat = 20
    static let lg: CGFloat = 32
    static let xl: CGFloat = 48
}

// MARK: - Corner Radius

enum CornerRadius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 14
}

// MARK: - Border Width

enum BorderWidth {
    static let thin: CGFloat = 1
    static let medium: CGFloat = 1.5
}

// MARK: - Opacity

enum Opacity {
    static let muted: Double = 0.6
    static let subtle: Double = 0.1
}
