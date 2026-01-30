import SwiftUI

// MARK: - Colors
// "Spotter" Design System - Cool, supportive, friendly gym buddy aesthetic

extension Color {
    // Core palette - deep blue-gray foundation (cool, calm, focused)
    static let spotterBackground = Color(hex: "0F172A")      // Slate-900: deep but not harsh
    static let spotterSurface = Color(hex: "1E293B")         // Slate-800: elevated surfaces
    static let spotterSurfaceElevated = Color(hex: "334155") // Slate-700: cards, modals

    // Primary accent - teal/cyan (supportive, fresh, energetic)
    static let spotterPrimary = Color(hex: "06B6D4")         // Cyan-500: friendly, cool
    static let spotterPrimaryHover = Color(hex: "0891B2")    // Cyan-600: pressed states
    static let spotterPrimaryMuted = Color(hex: "06B6D4").opacity(0.15)

    // Text hierarchy - clean whites and cool grays
    static let spotterText = Color(hex: "F8FAFC")            // Slate-50: primary text
    static let spotterTextSecondary = Color(hex: "94A3B8")   // Slate-400: readable secondary
    static let spotterTextMuted = Color(hex: "64748B")       // Slate-500: tertiary/disabled

    // Borders and dividers - subtle cool definition
    static let spotterBorder = Color(hex: "334155")          // Slate-700: subtle dividers
    static let spotterBorderLight = Color(hex: "475569")     // Slate-600: more prominent

    // Semantic colors - friendly and clear
    static let spotterSuccess = Color(hex: "10B981")         // Emerald-500: achievements
    static let spotterSuccessMuted = Color(hex: "10B981").opacity(0.15)
    static let spotterWarning = Color(hex: "F59E0B")         // Amber-500: caution
    static let spotterError = Color(hex: "F87171")           // Red-400: softer error

    // RPE intensity gradient - cool to warm
    static let spotterRPE6 = Color(hex: "10B981")            // Emerald: easy
    static let spotterRPE7 = Color(hex: "06B6D4")            // Cyan: moderate
    static let spotterRPE8 = Color(hex: "FBBF24")            // Amber: challenging
    static let spotterRPE9 = Color(hex: "FB923C")            // Orange: hard
    static let spotterRPE10 = Color(hex: "F87171")           // Red: max effort

    // Gradient stops - cool supportive vibe
    static let spotterGradientStart = Color(hex: "06B6D4")   // Cyan
    static let spotterGradientEnd = Color(hex: "8B5CF6")     // Violet-500

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

// MARK: - Gradients

extension LinearGradient {
    // Primary action gradient - fiery, energetic
    static let spotterPrimaryGradient = LinearGradient(
        colors: [Color.spotterGradientStart, Color.spotterGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Subtle surface gradient - depth without distraction
    static let spotterSurfaceGradient = LinearGradient(
        colors: [Color.spotterSurface, Color.spotterSurfaceElevated.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )

    // Card highlight - subtle glow on top edge
    static let spotterCardHighlight = LinearGradient(
        colors: [Color.white.opacity(0.05), Color.clear],
        startPoint: .top,
        endPoint: .center
    )
}

// MARK: - Fonts
// Clean, friendly typography - readable and approachable

extension Font {
    // Display - big but not overwhelming
    static let spotterDisplay = Font.system(size: 44, weight: .bold, design: .rounded)

    // Title - clear hierarchy
    static let spotterTitle = Font.system(size: 24, weight: .bold, design: .rounded)
    static let spotterTitleSecondary = Font.system(size: 20, weight: .semibold, design: .rounded)

    // Headline - section headers
    static let spotterHeadline = Font.system(size: 17, weight: .semibold, design: .default)

    // Body - comfortable reading
    static let spotterBody = Font.system(size: 16, weight: .regular, design: .default)
    static let spotterBodyMedium = Font.system(size: 16, weight: .medium, design: .default)

    // Caption - secondary info
    static let spotterCaption = Font.system(size: 13, weight: .regular, design: .default)
    static let spotterCaptionMedium = Font.system(size: 13, weight: .medium, design: .default)

    // Label - buttons, UI elements
    static let spotterLabel = Font.system(size: 16, weight: .semibold, design: .default)

    // Large numbers - scaled down for better fit
    static let spotterLargeNumber = Font.system(size: 48, weight: .bold, design: .rounded)
    static let spotterMediumNumber = Font.system(size: 32, weight: .bold, design: .rounded)

    // Monospace for timers
    static let spotterTimer = Font.system(size: 18, weight: .medium, design: .monospaced)
}

// MARK: - Spacing
// Comfortable spacing - room to breathe

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 56
}

// MARK: - Corner Radius
// Rounded but not bubbly - confident, modern

enum CornerRadius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let full: CGFloat = 9999 // Pill shape
}

// MARK: - Border Width

enum BorderWidth {
    static let thin: CGFloat = 1
    static let medium: CGFloat = 1.5
    static let thick: CGFloat = 2
}

// MARK: - Shadows
// Subtle depth without being heavy

enum SpotterShadow {
    static let sm = Shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    static let md = Shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
    static let lg = Shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
    static let glow = Shadow(color: Color.spotterPrimary.opacity(0.4), radius: 12, x: 0, y: 0)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Animation
// Snappy, responsive feel

enum SpotterAnimation {
    static let quick = Animation.spring(response: 0.25, dampingFraction: 0.8)
    static let standard = Animation.spring(response: 0.35, dampingFraction: 0.75)
    static let bounce = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let smooth = Animation.easeInOut(duration: 0.3)
}

// MARK: - Opacity

enum Opacity {
    static let muted: Double = 0.6
    static let subtle: Double = 0.1
    static let disabled: Double = 0.4
}

// MARK: - View Extensions

extension View {
    func spotterShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    func spotterCardStyle() -> some View {
        self
            .background(Color.spotterSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.spotterBorder, lineWidth: BorderWidth.thin)
            )
    }

    func spotterGlow() -> some View {
        self.shadow(color: Color.spotterPrimary.opacity(0.4), radius: 12, x: 0, y: 0)
    }
}
