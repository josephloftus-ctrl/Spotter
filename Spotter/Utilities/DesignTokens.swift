import SwiftUI

// MARK: - Colors
// "Forge" Design System - Dark, powerful, premium fitness aesthetic

extension Color {
    // Core palette - deep charcoal foundation
    static let spotterBackground = Color(hex: "0D0D0F")      // Near-black with subtle warmth
    static let spotterSurface = Color(hex: "18181B")         // Elevated surfaces
    static let spotterSurfaceElevated = Color(hex: "27272A") // Cards, modals

    // Primary accent - molten copper/amber (evokes heat, intensity)
    static let spotterPrimary = Color(hex: "F59E0B")         // Amber-500: energetic, warm
    static let spotterPrimaryHover = Color(hex: "D97706")    // Amber-600: pressed states
    static let spotterPrimaryMuted = Color(hex: "F59E0B").opacity(0.15)

    // Text hierarchy - crisp whites and warm grays
    static let spotterText = Color(hex: "FAFAFA")            // Primary text: bright, clean
    static let spotterTextSecondary = Color(hex: "A1A1AA")   // Zinc-400: readable secondary
    static let spotterTextMuted = Color(hex: "71717A")       // Zinc-500: tertiary/disabled

    // Borders and dividers - subtle definition
    static let spotterBorder = Color(hex: "27272A")          // Zinc-800: subtle dividers
    static let spotterBorderLight = Color(hex: "3F3F46")     // Zinc-700: more prominent

    // Semantic colors - vibrant but not garish
    static let spotterSuccess = Color(hex: "22C55E")         // Green-500: achievements
    static let spotterSuccessMuted = Color(hex: "22C55E").opacity(0.15)
    static let spotterWarning = Color(hex: "EAB308")         // Yellow-500: caution
    static let spotterError = Color(hex: "EF4444")           // Red-500: errors

    // RPE intensity gradient - heat scale
    static let spotterRPE6 = Color(hex: "22C55E")            // Green: easy
    static let spotterRPE7 = Color(hex: "84CC16")            // Lime: moderate
    static let spotterRPE8 = Color(hex: "EAB308")            // Yellow: challenging
    static let spotterRPE9 = Color(hex: "F97316")            // Orange: hard
    static let spotterRPE10 = Color(hex: "EF4444")           // Red: max effort

    // Gradient stops for premium effects
    static let spotterGradientStart = Color(hex: "F59E0B")   // Amber
    static let spotterGradientEnd = Color(hex: "DC2626")     // Red-600

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
// Bold, confident typography with dramatic weight contrast

extension Font {
    // Display - massive, impactful (for hero numbers, main metrics)
    static let spotterDisplay = Font.system(size: 56, weight: .bold, design: .rounded)

    // Title - commanding presence
    static let spotterTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let spotterTitleSecondary = Font.system(size: 22, weight: .semibold, design: .rounded)

    // Headline - section headers, important labels
    static let spotterHeadline = Font.system(size: 17, weight: .semibold, design: .default)

    // Body - primary reading text
    static let spotterBody = Font.system(size: 16, weight: .regular, design: .default)
    static let spotterBodyMedium = Font.system(size: 16, weight: .medium, design: .default)

    // Caption - secondary info, metadata
    static let spotterCaption = Font.system(size: 13, weight: .regular, design: .default)
    static let spotterCaptionMedium = Font.system(size: 13, weight: .medium, design: .default)

    // Label - UI elements, buttons
    static let spotterLabel = Font.system(size: 15, weight: .semibold, design: .default)

    // Large numbers - workout metrics (weight, reps)
    static let spotterLargeNumber = Font.system(size: 64, weight: .bold, design: .rounded)
    static let spotterMediumNumber = Font.system(size: 36, weight: .bold, design: .rounded)

    // Monospace for timers
    static let spotterTimer = Font.system(size: 20, weight: .medium, design: .monospaced)
}

// MARK: - Spacing
// Generous spacing for touch targets and visual breathing room

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
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
