import SwiftUI

/// Hero surface matching the highlighted Figma frame (Daily Journal pill + warm gradient entry).
struct JournalHeroView: View {
    var summary: JournalHeroSummary
    var onReflect: (() -> Void)?

    init(summary: JournalHeroSummary = .preview, onReflect: (() -> Void)? = nil) {
        self.summary = summary
        self.onReflect = onReflect
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 32) {
                badgeHeader
                entryCard

                if let onReflect {
                    ReflectButton(title: summary.ctaTitle, action: onReflect)
                }
            }
            .frame(maxWidth: 920)
            .padding(.horizontal, 28)
            .padding(.vertical, 36)
        }
    }
}

// MARK: - Layers

private extension JournalHeroView {
    var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DayflowColors.accent,
                    DayflowColors.accent.opacity(0.7),
                    DayflowColors.accent.opacity(0.3),
                    DayflowColors.surface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [DayflowColors.background.opacity(0.9), Color.clear],
                center: .bottomLeading,
                startRadius: 90,
                endRadius: 520
            )
            .blendMode(.screen)
            .ignoresSafeArea()

            RadialGradient(
                colors: [DayflowColors.accent.opacity(0.45), Color.clear],
                center: .topLeading,
                startRadius: 140,
                endRadius: 520
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Components

private extension JournalHeroView {
    var badgeHeader: some View {
        Text(summary.headline)
            .font(.custom("Nunito-SemiBold", size: 30))
            .kerning(-0.4)
            .foregroundStyle(.clear) // fill via gradient mask
            .overlay(
                JournalHeroTokens.badgeTextGradient
                    .mask(
                        Text(summary.headline)
                            .font(.custom("Nunito-SemiBold", size: 30))
                            .kerning(-0.4)
                    )
            )
            .padding(.horizontal, 30)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(JournalHeroTokens.badgeBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(JournalHeroTokens.badgeStroke, lineWidth: 1)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(JournalHeroTokens.badgeInnerHighlight, lineWidth: 0.6)
                    .blur(radius: 0.8)
            )
            .shadow(color: JournalHeroTokens.badgeShadow, radius: 18, y: 12)
    }

    var entryCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(JournalHeroTokens.entryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(JournalHeroTokens.entryStroke, lineWidth: 1)
                )
                .shadow(color: JournalHeroTokens.entryShadow, radius: 30, y: 18)

            Text(summary.entry)
                .lineSpacing(8)
                .kerning(-0.2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 26)
                .padding(.vertical, 24)
                .multilineTextAlignment(.leading)

            // Fade out toward the bottom to mirror the Figma glow
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(JournalHeroTokens.entryFade)
                .allowsHitTesting(false)
        }
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ReflectButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Nunito-SemiBold", size: 15))
        }
        .buttonStyle(JournalHeroPillButtonStyle())
    }
}

private struct JournalHeroPillButtonStyle: ButtonStyle {
    var horizontalPadding: CGFloat = 24
    var verticalPadding: CGFloat = 10

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(DayflowColors.textPrimary.opacity(0.8))
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(DayflowColors.surface.opacity(configuration.isPressed ? 0.7 : 0.6))
            .cornerRadius(100)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .inset(by: 0.5)
                    .stroke(DayflowColors.borderSubtle, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
            .pointingHandCursor()
    }
}

// MARK: - Models

struct JournalHeroSummary {
    var headline: String
    var entry: AttributedString
    var ctaTitle: String
}

extension JournalHeroSummary {
    static var preview: JournalHeroSummary {
        .init(
            headline: "Daily Journal",
            entry: .sampleEntry,
            ctaTitle: "Reflect with Dayflow"
        )
    }
}

private extension AttributedString {
    static var sampleEntry: AttributedString {
        var base = AttributeContainer()
        base.font = .custom("InstrumentSerif-Regular", size: 30)
        base.foregroundColor = JournalHeroTokens.entryPrimary

        var emphasized = AttributeContainer()
        emphasized.font = .custom("InstrumentSerif-Regular", size: 32)
        emphasized.foregroundColor = JournalHeroTokens.entryEmphasis

        var secondary = AttributeContainer()
        secondary.font = .custom("InstrumentSerif-Regular", size: 28)
        secondary.foregroundColor = JournalHeroTokens.entrySecondary

        var text = AttributedString("Started the morning deep in debugging mode around ", attributes: base)
        text += AttributedString("8:45 AM", attributes: emphasized)
        text += AttributedString(", wrestling with dashboard cards that refused to ", attributes: base)
        text += AttributedString("show up.", attributes: emphasized)
        text += AttributedString(" Classic case of “why isn’t this simple thing working?” Had to dig through using Claude and even fire up Beekeeper Studio to check logs.", attributes: secondary)
        return text
    }
}

// MARK: - Tokens

private enum JournalHeroTokens {
    static let badgeTextGradient = LinearGradient(
        colors: [DayflowColors.accent, DayflowColors.accent],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let badgeBackground = LinearGradient(
        colors: [DayflowColors.surface.opacity(0.96), DayflowColors.surface],
        startPoint: .top,
        endPoint: .bottom
    )

    static let badgeStroke = DayflowColors.surface.opacity(0.65)
    static let badgeInnerHighlight = DayflowColors.surface.opacity(0.32)
    static let badgeShadow = DayflowColors.accent.opacity(0.38)

    static let entryBackground = DayflowColors.surface.opacity(0.36)
    static let entryStroke = DayflowColors.surface.opacity(0.62)
    static let entryShadow = DayflowColors.accent.opacity(0.14)
    static let entryPrimary = DayflowColors.textPrimary
    static let entrySecondary = DayflowColors.textMuted.opacity(0.86)
    static let entryEmphasis = DayflowColors.textPrimary
    static let entryFade = LinearGradient(
        colors: [Color.clear, DayflowColors.surface.opacity(0.94)],
        startPoint: .center,
        endPoint: .bottom
    )

    static let ctaBackground = LinearGradient(
        colors: [DayflowColors.accent.opacity(0.4), DayflowColors.accent.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let ctaStroke = DayflowColors.accent
    static let ctaText = DayflowColors.textPrimary
    static let ctaShadow = DayflowColors.accent.opacity(0.30)
}

// MARK: - Preview

struct JournalHeroView_Previews: PreviewProvider {
    static var previews: some View {
        JournalHeroView()
            .frame(width: 1180, height: 820)
    }
}
