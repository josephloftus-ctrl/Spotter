import SwiftUI

// MARK: - Colors
// "Liquid Glass" Design System - Translucent, luminous, fluid

extension Color {
    // Core palette - deep rich backgrounds for glass to pop
    static let spotterBackground = Color(hex: "0C0C14")      // Deep indigo-black
    static let spotterSurface = Color(hex: "16162A")         // Slightly elevated
    static let spotterSurfaceElevated = Color(hex: "1E1E3A") // Glass card base

    // Glass tints - for translucent overlays
    static let spotterGlassTint = Color.white.opacity(0.08)
    static let spotterGlassHighlight = Color.white.opacity(0.15)
    static let spotterGlassBorder = Color.white.opacity(0.12)

    // Primary accent - vibrant cyan that glows
    static let spotterPrimary = Color(hex: "22D3EE")         // Cyan-400: bright, glowing
    static let spotterPrimaryHover = Color(hex: "06B6D4")    // Cyan-500: pressed
    static let spotterPrimaryMuted = Color(hex: "22D3EE").opacity(0.12)
    static let spotterPrimaryGlow = Color(hex: "22D3EE").opacity(0.4)

    // Text - crisp and luminous
    static let spotterText = Color(hex: "FFFFFF")            // Pure white for glass
    static let spotterTextSecondary = Color(hex: "A5B4CB")   // Cool gray
    static let spotterTextMuted = Color(hex: "6B7A99")       // Muted

    // Borders - subtle glass edges
    static let spotterBorder = Color.white.opacity(0.08)
    static let spotterBorderLight = Color.white.opacity(0.15)

    // Semantic colors - vibrant on dark glass
    static let spotterSuccess = Color(hex: "34D399")         // Emerald-400: bright
    static let spotterSuccessMuted = Color(hex: "34D399").opacity(0.15)
    static let spotterWarning = Color(hex: "FBBF24")         // Amber-400
    static let spotterError = Color(hex: "FB7185")           // Rose-400

    // RPE intensity - glowing scale
    static let spotterRPE6 = Color(hex: "34D399")            // Emerald
    static let spotterRPE7 = Color(hex: "22D3EE")            // Cyan
    static let spotterRPE8 = Color(hex: "FBBF24")            // Amber
    static let spotterRPE9 = Color(hex: "FB923C")            // Orange
    static let spotterRPE10 = Color(hex: "FB7185")           // Rose

    // Gradient stops - ethereal glow
    static let spotterGradientStart = Color(hex: "22D3EE")   // Cyan
    static let spotterGradientMid = Color(hex: "A78BFA")     // Violet-400
    static let spotterGradientEnd = Color(hex: "F472B6")     // Pink-400

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
    // Primary action gradient - vibrant cyan to violet
    static let spotterPrimaryGradient = LinearGradient(
        colors: [Color.spotterGradientStart, Color.spotterGradientMid, Color.spotterGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Glass highlight - top edge shine
    static let spotterGlassHighlightGradient = LinearGradient(
        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )

    // Glass edge - subtle border glow
    static let spotterGlassEdge = LinearGradient(
        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Card highlight - subtle inner glow
    static let spotterCardHighlight = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.clear],
        startPoint: .top,
        endPoint: .center
    )

    // Mesh-style background gradient
    static let spotterMeshGradient = LinearGradient(
        colors: [
            Color(hex: "0C0C14"),
            Color(hex: "0F1629"),
            Color(hex: "0C0C14")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
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
