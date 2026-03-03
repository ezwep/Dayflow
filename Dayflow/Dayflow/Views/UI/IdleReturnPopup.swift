import SwiftUI

struct IdleReturnPopup: View {
    let idleStartedAt: Date
    let idleEndedAt: Date
    let onSave: (String) -> Void
    let onSkip: () -> Void

    @State private var description: String = ""
    @FocusState private var isDescriptionFocused: Bool

    private let displayTimeFormatter: DateFormatter = DateFormatter()

    private func displayTime(from date: Date) -> String {
        TimeFormatPreferences.applyDisplayFormat(to: displayTimeFormatter)
        return displayTimeFormatter.string(from: date)
    }

    private var durationMinutes: Int {
        Int(idleEndedAt.timeIntervalSince(idleStartedAt) / 60)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0.62, green: 0.44, blue: 0.36))

                Text("You were away")
                    .font(.custom("Nunito", size: 16).weight(.bold))
                    .foregroundColor(DayflowColors.textPrimary)
            }

            HStack(spacing: 6) {
                Text(displayTime(from: idleStartedAt))
                    .font(.custom("Nunito", size: 13).weight(.semibold))
                    .foregroundColor(DayflowColors.accent)

                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(DayflowColors.textMuted)

                Text(displayTime(from: idleEndedAt))
                    .font(.custom("Nunito", size: 13).weight(.semibold))
                    .foregroundColor(DayflowColors.accent)

                Text("(\(durationMinutes) min)")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(DayflowColors.textMuted)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DayflowColors.accent.opacity(0.15))
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("What were you doing?")
                    .font(.custom("Nunito", size: 13))
                    .foregroundColor(DayflowColors.textPrimary)

                TextField("e.g. In a meeting, lunch break, phone call...", text: $description)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom("Nunito", size: 13))
                    .focused($isDescriptionFocused)
                    .onSubmit {
                        if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave(description.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
            }

            HStack(spacing: 10) {
                Button(action: {
                    let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        onSave(trimmed)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Add to timeline")
                            .font(.custom("Nunito", size: 13).weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DayflowColors.accent)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)

                Button(action: onSkip) {
                    Text("Skip")
                        .font(.custom("Nunito", size: 13))
                        .foregroundColor(DayflowColors.textMuted)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DayflowColors.surface.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.98, green: 0.76, blue: 0.42).opacity(0.5), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .frame(width: 380)
        .dayflowGlass(cornerRadius: 14)
        .onAppear {
            isDescriptionFocused = true
        }
    }
}
