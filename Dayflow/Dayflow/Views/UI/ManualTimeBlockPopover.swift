import SwiftUI

struct ManualTimeBlockPopover: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    let onSave: (Date, Date, String, String) -> Void  // start, end, description, category
    let onCancel: () -> Void
    var isEditing: Bool = false
    var initialDescription: String = ""
    var initialCategory: String = "Personal"
    var categories: [TimelineCategory] = []

    @State private var description: String = ""
    @State private var selectedCategory: String = "Personal"
    @FocusState private var isDescriptionFocused: Bool

    private let displayTimeFormatter = DateFormatter()

    private func displayTime(from date: Date) -> String {
        TimeFormatPreferences.applyDisplayFormat(to: displayTimeFormatter)
        return displayTimeFormatter.string(from: date)
    }

    private var durationMinutes: Int {
        max(1, Int(endTime.timeIntervalSince(startTime) / 60))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: isEditing ? "pencil.circle" : "plus.rectangle.on.rectangle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.62, green: 0.44, blue: 0.36))

                Text(isEditing ? "Edit time block" : "Add time block")
                    .font(.custom("Nunito", size: 15).weight(.bold))
                    .foregroundColor(.black.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start")
                            .font(.custom("Nunito", size: 11))
                            .foregroundColor(.black.opacity(0.5))
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }

                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.black.opacity(0.35))
                        .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("End")
                            .font(.custom("Nunito", size: 11))
                            .foregroundColor(.black.opacity(0.5))
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }

                    Text("(\(durationMinutes) min)")
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(.black.opacity(0.5))
                        .padding(.top, 16)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Description")
                    .font(.custom("Nunito", size: 13))
                    .foregroundColor(.black.opacity(0.7))

                TextField("What were you doing?", text: $description)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom("Nunito", size: 13))
                    .focused($isDescriptionFocused)
                    .onSubmit {
                        saveIfValid()
                    }
            }

            // Category selection
            if !categories.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Category")
                        .font(.custom("Nunito", size: 13))
                        .foregroundColor(.black.opacity(0.7))

                    CategoryWrappingLayout(categories: categories.filter { !$0.isSystem }, selectedCategory: $selectedCategory)
                }
            }

            HStack(spacing: 10) {
                Button(action: saveIfValid) {
                    HStack(spacing: 6) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text(isEditing ? "Save" : "Add")
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
                .disabled(!isValid)
                .opacity(isValid ? 1.0 : 0.5)

                Button(action: onCancel) {
                    Text("Cancel")
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
        .padding(18)
        .frame(width: 360)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 1.0, green: 0.97, blue: 0.93))
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.98, green: 0.76, blue: 0.42).opacity(0.4), lineWidth: 1)
                )
        )
        .onAppear {
            if isEditing {
                description = initialDescription
                selectedCategory = initialCategory
            } else {
                selectedCategory = initialCategory
            }
            isDescriptionFocused = true
        }
    }

    private var isValid: Bool {
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && endTime > startTime
    }

    private func saveIfValid() {
        guard isValid else { return }
        onSave(startTime, endTime, description.trimmingCharacters(in: .whitespacesAndNewlines), selectedCategory)
    }
}

// MARK: - Wrapping layout for category pills

private struct CategoryWrappingLayout: View {
    let categories: [TimelineCategory]
    @Binding var selectedCategory: String

    @State private var totalHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(categories, id: \.id) { category in
                categoryPill(for: category)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > geo.size.width {
                            width = 0
                            height -= d.height + 6
                        }
                        let result = width
                        if category.id == categories.last?.id {
                            width = 0
                        } else {
                            width -= d.width + 6
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if category.id == categories.last?.id {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: HeightPreferenceKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { h in
            totalHeight = h
        }
    }

    private func categoryPill(for category: TimelineCategory) -> some View {
        let isSelected = selectedCategory == category.name
        return Button(action: {
            selectedCategory = category.name
        }) {
            HStack(spacing: 5) {
                Circle()
                    .fill(Color(hex: category.colorHex))
                    .frame(width: 10, height: 10)
                Text(category.name)
                    .font(.custom("Nunito", size: 12).weight(isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .black.opacity(0.9) : .black.opacity(0.55))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(isSelected ? Color(hex: category.colorHex).opacity(0.7) : Color.black.opacity(0.08), lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
