import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header (matches Timeline positioning & padding is applied on parent)
            Text("Dashboard")
                .font(.custom("InstrumentSerif-Regular", size: 42))
                .foregroundColor(DayflowColors.textPrimary)
                .padding(.leading, 10) // Match Timeline header inset

            // Chat interface
            ChatView()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [DayflowColors.surface, DayflowColors.surfaceElevated],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(DayflowColors.border, lineWidth: 1)
                )
                .shadow(color: Color(hex: "D99A5A").opacity(0.14), radius: 16, x: 0, y: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
