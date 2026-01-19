import SwiftUI

// MARK: - Colors

extension Color {
    static let spotterPrimary = Color("SpotterPrimary")
    static let spotterSecondary = Color("SpotterSecondary")
    static let spotterBackground = Color("SpotterBackground")
    static let spotterSurface = Color("SpotterSurface")
    static let spotterText = Color("SpotterText")
    static let spotterTextSecondary = Color("SpotterTextSecondary")
    static let spotterSuccess = Color("SpotterSuccess")
    static let spotterWarning = Color("SpotterWarning")

    // Fallback colors if asset catalog not configured
    static let spotterPrimaryFallback = Color.blue
    static let spotterSecondaryFallback = Color.gray
    static let spotterBackgroundFallback = Color(uiColor: .systemBackground)
    static let spotterSurfaceFallback = Color(uiColor: .secondarySystemBackground)
    static let spotterTextFallback = Color(uiColor: .label)
    static let spotterTextSecondaryFallback = Color(uiColor: .secondaryLabel)
    static let spotterSuccessFallback = Color.green
    static let spotterWarningFallback = Color.orange
}

// MARK: - Fonts

extension Font {
    static let spotterTitle = Font.system(.title, design: .rounded, weight: .bold)
    static let spotterHeadline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let spotterBody = Font.system(.body, design: .default)
    static let spotterCaption = Font.system(.caption, design: .default)
    static let spotterLargeNumber = Font.system(size: 48, weight: .bold, design: .rounded)
}

// MARK: - Spacing

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Corner Radius

enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
}
