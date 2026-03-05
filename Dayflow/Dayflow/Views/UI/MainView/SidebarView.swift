import SwiftUI

enum SidebarIcon: String, CaseIterable {
    case timeline
    case daily
    case dashboard
    case journal
    case bug
    case settings

    var assetName: String? {
        switch self {
        case .timeline: return "TimelineIcon"
        case .daily: return nil
        case .dashboard: return "DashboardIcon"
        case .journal: return "JournalIcon"
        case .bug: return nil
        case .settings: return nil
        }
    }

    var systemNameFallback: String? {
        switch self {
        case .daily: return "calendar"
        case .bug: return "exclamationmark.bubble"
        case .settings: return "gearshape"
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .timeline: return "Timeline"
        case .daily: return "Daily"
        case .dashboard: return "Dashboard"
        case .journal: return "Journal"
        case .bug: return "Report"
        case .settings: return "Settings"
        }
    }
}

struct SidebarView: View {
    @Binding var selectedIcon: SidebarIcon
    @ObservedObject private var badgeManager = NotificationBadgeManager.shared

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            ForEach(SidebarIcon.allCases, id: \.self) { icon in
                SidebarIconButton(
                    icon: icon,
                    isSelected: selectedIcon == icon,
                    showBadge: icon == .journal && badgeManager.hasPendingReminder,
                    action: { selectedIcon = icon }
                )
                .frame(width: 66, height: 66)
            }
        }
    }
}

struct SidebarIconButton: View {
    let icon: SidebarIcon
    let isSelected: Bool
    var showBadge: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(DayflowColors.accent.opacity(0.15))
                            .frame(width: 38, height: 38)
                    }

                    if let asset = icon.assetName {
                        Image(asset)
                            .resizable()
                            .interpolation(.high)
                            .renderingMode(.template)
                            .foregroundColor(isSelected ? DayflowColors.accent : DayflowColors.textMuted)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    } else if let sys = icon.systemNameFallback {
                        Image(systemName: sys)
                            .font(.system(size: 18))
                            .foregroundColor(isSelected ? DayflowColors.accent : DayflowColors.textMuted)
                    }

                    if showBadge {
                        Circle()
                            .fill(DayflowColors.accent)
                            .frame(width: 9, height: 9)
                            .offset(x: 13, y: -13)
                    }
                }
                .frame(width: 42, height: 42)

                Text(icon.displayName)
                    .font(.custom("Nunito", size: 12))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundColor(isSelected ? DayflowColors.accent : DayflowColors.textMuted)
            }
            .frame(width: 66, height: 66)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .hoverScaleEffect(scale: 1.02)
        .pointingHandCursor()
    }
}
