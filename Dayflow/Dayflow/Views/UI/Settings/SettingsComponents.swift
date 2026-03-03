import SwiftUI

struct SettingsCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: () -> Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom("Nunito", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(DayflowColors.textPrimary.opacity(0.85))
                if let subtitle {
                    Text(subtitle)
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(DayflowColors.textMuted)
                }
            }
            content()
        }
        .padding(28)
        .dayflowGlass(cornerRadius: 18)
    }
}
