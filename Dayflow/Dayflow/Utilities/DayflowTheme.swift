import SwiftUI

// MARK: - Notifications

extension Notification.Name {
    static let dayflowAppearanceChanged = Notification.Name("dayflowAppearanceChanged")
}

// MARK: - Appearance Preference

enum DayflowAppearance: String, CaseIterable {
    case dark = "dark"
    case light = "light"
    case system = "system"

    var colorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }

    var label: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        case .system: return "System"
        }
    }
}

// MARK: - Color Tokens

struct DayflowColors {

    // MARK: - Backgrounds

    /// Main window background
    /// Dark: #0D1117 — Light: #F8FAFC
    static let background = Color("DFBackground")

    /// Surface color for panels, cards, modals
    /// Dark: #161B22 — Light: #FFFFFF
    static let surface = Color("DFSurface")

    /// Elevated surface (cards on top of surface)
    /// Dark: #1C2333 — Light: #FFFFFF
    static let surfaceElevated = Color("DFSurfaceElevated")

    // MARK: - Accent / Brand

    /// Primary accent — interactive elements, links, active states
    /// Dark: #00BFFF — Light: #4A6FA5
    static let accent = Color("DFAccent")

    /// Secondary accent — complementary highlights
    /// Dark: #7C3AED — Light: #2563EB
    static let secondary = Color("DFSecondary")

    /// CTA button background
    /// Dark: #00BFFF — Light: #2563EB
    static let cta = Color("DFCTA")

    // MARK: - Text

    /// Primary text
    /// Dark: #E6EDF3 — Light: #1E293B
    static let textPrimary = Color("DFTextPrimary")

    /// Secondary / muted text
    /// Dark: #8B949E — Light: #64748B
    static let textMuted = Color("DFTextMuted")

    // MARK: - Borders & Dividers

    /// Standard border
    /// Dark: #30363D — Light: #E2E8F0
    static let border = Color("DFBorder")

    /// Subtle border for glass surfaces
    /// Dark: white 10% — Light: black 6%
    static let borderSubtle = Color("DFBorderSubtle")

    // MARK: - Semantic

    static let success = Color("DFSuccess")
    static let warning = Color("DFWarning")
    static let error = Color("DFError")

    // MARK: - Glass

    /// Glass overlay tint
    /// Dark: white 5% — Light: white 72%
    static let glassTint = Color("DFGlassTint")

    /// Glass border
    /// Dark: white 10% — Light: white 55%
    static let glassBorder = Color("DFGlassBorder")
}

// MARK: - Glass Effect Modifier

struct DayflowGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 18
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(scheme == .dark ? .ultraThinMaterial : .regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(DayflowColors.glassBorder, lineWidth: 0.8)
                    )
                    .shadow(color: .black.opacity(scheme == .dark ? 0.3 : 0.08), radius: 18, x: 0, y: 12)
            }
    }
}

extension View {
    func dayflowGlass(cornerRadius: CGFloat = 18) -> some View {
        modifier(DayflowGlassModifier(cornerRadius: cornerRadius))
    }
}
