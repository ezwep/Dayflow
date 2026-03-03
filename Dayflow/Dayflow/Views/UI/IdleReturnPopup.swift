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
                    .foregroundColor(.black.opacity(0.85))
            }

            HStack(spacing: 6) {
                Text(displayTime(from: idleStartedAt))
                    .font(.custom("Nunito", size: 13).weight(.semibold))
                    .foregroundColor(Color(red: 0.25, green: 0.17, blue: 0))

                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.black.opacity(0.35))

                Text(displayTime(from: idleEndedAt))
                    .font(.custom("Nunito", size: 13).weight(.semibold))
                    .foregroundColor(Color(red: 0.25, green: 0.17, blue: 0))

                Text("(\(durationMinutes) min)")
                    .font(.custom("Nunito", size: 12))
                    .foregroundColor(.black.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 1.0, green: 0.88, blue: 0.65).opacity(0.3))
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("What were you doing?")
                    .font(.custom("Nunito", size: 13))
                    .foregroundColor(.black.opacity(0.7))

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
                            .fill(Color(red: 0.25, green: 0.17, blue: 0))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)

                Button(action: onSkip) {
                    Text("Skip")
                        .font(.custom("Nunito", size: 13))
                        .foregroundColor(.black.opacity(0.55))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.7))
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
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 1.0, green: 0.97, blue: 0.93))
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.98, green: 0.76, blue: 0.42).opacity(0.4), lineWidth: 1)
                )
        )
        .onAppear {
            isDescriptionFocused = true
        }
    }
}
