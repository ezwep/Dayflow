import AppKit
import Combine
import SwiftUI

// MARK: - Theme Definitions

enum DayflowThemeId: String, CaseIterable, Identifiable {
    case ocean
    case sunset
    case forest
    case lavender

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ocean:    return "Ocean"
        case .sunset:   return "Sunset"
        case .forest:   return "Forest"
        case .lavender: return "Lavender"
        }
    }

    /// The swatch color shown in the theme picker (dark-mode accent).
    var swatchColor: NSColor {
        palette.accentDark
    }
}

// MARK: - Palette

struct ThemePalette {
    let accentDark: NSColor
    let accentLight: NSColor
    let secondaryDark: NSColor
    let secondaryLight: NSColor
    let ctaDark: NSColor
    let ctaLight: NSColor

    func accent(isDark: Bool) -> NSColor {
        isDark ? accentDark : accentLight
    }

    func secondary(isDark: Bool) -> NSColor {
        isDark ? secondaryDark : secondaryLight
    }

    func cta(isDark: Bool) -> NSColor {
        isDark ? ctaDark : ctaLight
    }
}

extension DayflowThemeId {
    var palette: ThemePalette {
        switch self {
        case .ocean:
            return ThemePalette(
                accentDark:     NSColor(hex: "00BFFF")!,
                accentLight:    NSColor(hex: "4A6FA5")!,
                secondaryDark:  NSColor(hex: "7C3AED")!,
                secondaryLight: NSColor(hex: "2563EB")!,
                ctaDark:        NSColor(hex: "00BFFF")!,
                ctaLight:       NSColor(hex: "2563EB")!
            )
        case .sunset:
            return ThemePalette(
                accentDark:     NSColor(hex: "FF6B6B")!,
                accentLight:    NSColor(hex: "C44536")!,
                secondaryDark:  NSColor(hex: "FFB347")!,
                secondaryLight: NSColor(hex: "D97706")!,
                ctaDark:        NSColor(hex: "FF6B6B")!,
                ctaLight:       NSColor(hex: "C44536")!
            )
        case .forest:
            return ThemePalette(
                accentDark:     NSColor(hex: "4ADE80")!,
                accentLight:    NSColor(hex: "16A34A")!,
                secondaryDark:  NSColor(hex: "34D399")!,
                secondaryLight: NSColor(hex: "059669")!,
                ctaDark:        NSColor(hex: "4ADE80")!,
                ctaLight:       NSColor(hex: "16A34A")!
            )
        case .lavender:
            return ThemePalette(
                accentDark:     NSColor(hex: "A78BFA")!,
                accentLight:    NSColor(hex: "7C3AED")!,
                secondaryDark:  NSColor(hex: "C084FC")!,
                secondaryLight: NSColor(hex: "9333EA")!,
                ctaDark:        NSColor(hex: "A78BFA")!,
                ctaLight:       NSColor(hex: "7C3AED")!
            )
        }
    }
}

// MARK: - Theme Manager

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    /// Incremented on every theme change; bind root view's .id() to this.
    @Published private(set) var revision: Int = 0

    @Published var currentTheme: DayflowThemeId {
        didSet {
            guard currentTheme != oldValue else { return }
            cachedPalette = currentTheme.palette
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "dayflowTheme")
            revision += 1
            NotificationCenter.default.post(name: .dayflowThemeChanged, object: currentTheme.rawValue)
        }
    }

    var currentPalette: ThemePalette {
        currentTheme.palette
    }

    /// Nonisolated cache so NSColor dynamic closures can read the palette without @MainActor.
    nonisolated(unsafe) private(set) var cachedPalette: ThemePalette = DayflowThemeId.ocean.palette

    private init() {
        let stored = UserDefaults.standard.string(forKey: "dayflowTheme") ?? "ocean"
        let theme = DayflowThemeId(rawValue: stored) ?? .ocean
        self.currentTheme = theme
        self.cachedPalette = theme.palette
    }
}

extension Notification.Name {
    static let dayflowThemeChanged = Notification.Name("dayflowThemeChanged")
}
