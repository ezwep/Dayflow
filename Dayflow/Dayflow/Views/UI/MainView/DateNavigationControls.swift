import SwiftUI
import AppKit

struct DateNavigationControls: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    @Binding var lastDateNavMethod: String?
    @Binding var previousDate: Date

    @State private var showPopover = false

    var body: some View {
        HStack(spacing: 12) {
            DayflowCircleButton {
                let from = selectedDate
                let to = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                previousDate = selectedDate
                selectedDate = normalizedTimelineDate(to)
                lastDateNavMethod = "prev"
                AnalyticsService.shared.capture("date_navigation", [
                    "method": "prev",
                    "from_day": dayString(from),
                    "to_day": dayString(to)
                ])
            } content: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DayflowColors.textMuted)
            }

            DayflowPillButton(
                text: formatDateForDisplay(selectedDate),
                fixedWidth: calculateOptimalPillWidth()
            )
            .contentShape(Rectangle())
            .onTapGesture { showPopover = true; lastDateNavMethod = "picker" }
            .pointingHandCursor()
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                InlineDatePicker(selectedDate: $selectedDate, isPresented: $showPopover) { newDate in
                    lastDateNavMethod = "picker"
                    previousDate = selectedDate
                    selectedDate = normalizedTimelineDate(newDate)
                }
            }

            DayflowCircleButton {
                guard canNavigateForward(from: selectedDate) else { return }
                let from = selectedDate
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                previousDate = selectedDate
                selectedDate = normalizedTimelineDate(tomorrow)
                lastDateNavMethod = "next"
                AnalyticsService.shared.capture("date_navigation", [
                    "method": "next",
                    "from_day": dayString(from),
                    "to_day": dayString(tomorrow)
                ])
            } content: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                        canNavigateForward(from: selectedDate)
                        ? DayflowColors.textMuted
                        : DayflowColors.textMuted.opacity(0.5)
                    )
            }
        }
    }

    private func formatDateForDisplay(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current

        let displayDate = timelineDisplayDate(from: date, now: now)
        let timelineToday = timelineDisplayDate(from: now, now: now)

        if calendar.isDate(displayDate, inSameDayAs: timelineToday) {
            return cachedTodayDisplayFormatter.string(from: displayDate)
        } else {
            return cachedOtherDayDisplayFormatter.string(from: displayDate)
        }
    }

    private func dayString(_ date: Date) -> String {
        return cachedDayStringFormatter.string(from: date)
    }

    private func calculateOptimalPillWidth() -> CGFloat {
        let sampleText = "Today, Sep 30"
        let nsFont = NSFont(name: "InstrumentSerif-Regular", size: 18) ?? NSFont.systemFont(ofSize: 18)
        let textSize = sampleText.size(withAttributes: [.font: nsFont])
        let horizontalPadding: CGFloat = 11.77829 * 2
        return textSize.width + horizontalPadding + 8
    }
}

/// Custom calendar popover matching the Dayflow design system
struct DateNavInlinePicker: View {
    @Binding var isPresented: Bool
    var initialDate: Date = Date()
    let onSelect: (Date) -> Void

    @State private var displayMonth: Date
    @State private var pickedDate: Date

    private let cal = Calendar.current
    private static let weekdayLabels = ["M", "D", "W", "D", "V", "Z", "Z"]

    init(isPresented: Binding<Bool>, initialDate: Date = Date(), onSelect: @escaping (Date) -> Void) {
        _isPresented = isPresented
        self.initialDate = initialDate
        self.onSelect = onSelect
        let c = Calendar.current
        let monthStart = c.date(from: c.dateComponents([.year, .month], from: initialDate)) ?? initialDate
        _displayMonth = State(initialValue: monthStart)
        _pickedDate = State(initialValue: initialDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            monthHeader
            weekdayRow
            dayGrid
            Divider()
                .background(DayflowColors.border.opacity(0.3))
                .padding(.horizontal, 16)
            vandaagButton
        }
        .frame(width: 310)
    }

    private var monthHeader: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DayflowColors.textMuted)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .pointingHandCursor()

            Spacer()

            Text(monthTitle(for: displayMonth))
                .font(.custom("Nunito", size: 14).weight(.semibold))
                .foregroundColor(DayflowColors.textPrimary)

            Spacer()

            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(canGoForward ? DayflowColors.textMuted : DayflowColors.textMuted.opacity(0.2))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .disabled(!canGoForward)
            .pointingHandCursor()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(Self.weekdayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.custom("Nunito", size: 11).weight(.bold))
                    .foregroundColor(DayflowColors.textMuted.opacity(0.5))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    private var dayGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
            spacing: 0
        ) {
            ForEach(calendarDays) { day in
                CalDayCell(
                    day: day,
                    isSelected: day.date.map { cal.isDate($0, inSameDayAs: pickedDate) } ?? false
                ) {
                    guard let date = day.date else { return }
                    pickedDate = date
                    onSelect(date)
                    isPresented = false
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    private var vandaagButton: some View {
        Button("Vandaag") {
            onSelect(Date())
            isPresented = false
        }
        .buttonStyle(.plain)
        .font(.custom("Nunito", size: 13).weight(.semibold))
        .foregroundColor(DayflowColors.accent)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
    }

    private func shiftMonth(_ delta: Int) {
        displayMonth = cal.date(byAdding: .month, value: delta, to: displayMonth) ?? displayMonth
    }

    private var canGoForward: Bool {
        guard let next = cal.date(byAdding: .month, value: 1, to: displayMonth) else { return false }
        let now = cal.dateComponents([.year, .month], from: Date())
        let nm = cal.dateComponents([.year, .month], from: next)
        return (nm.year! * 12 + nm.month!) <= (now.year! * 12 + now.month!)
    }

    private func monthTitle(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "nl_NL")
        fmt.dateFormat = "MMMM yyyy"
        let s = fmt.string(from: date)
        return s.prefix(1).uppercased() + s.dropFirst()
    }

    private var calendarDays: [CalDayItem] {
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: displayMonth) // Sun=1..Sat=7
        let offset = (weekday - 2 + 7) % 7                       // Mon=0..Sun=6
        let count = cal.range(of: .day, in: .month, for: displayMonth)!.count
        var days: [CalDayItem] = []
        for _ in 0..<offset {
            days.append(CalDayItem(day: 0, date: nil, isFuture: false, isEmpty: true))
        }
        for n in 1...count {
            let date = cal.date(byAdding: .day, value: n - 1, to: displayMonth)!
            days.append(CalDayItem(
                day: n,
                date: date,
                isFuture: cal.startOfDay(for: date) > today,
                isEmpty: false
            ))
        }
        return days
    }
}

private struct CalDayItem: Identifiable {
    let id = UUID()
    let day: Int
    let date: Date?
    let isFuture: Bool
    let isEmpty: Bool
}

private struct CalDayCell: View {
    let day: CalDayItem
    let isSelected: Bool
    let onTap: () -> Void

    private let cal = Calendar.current
    private var isToday: Bool { day.date.map { cal.isDateInToday($0) } ?? false }

    var body: some View {
        if day.isEmpty {
            Color.clear.frame(height: 36)
        } else {
            Button(action: onTap) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(DayflowColors.accent)
                            .frame(width: 32, height: 32)
                    } else if isToday {
                        Circle()
                            .strokeBorder(DayflowColors.accent, lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                    }
                    Text("\(day.day)")
                        .font(.custom("InstrumentSerif-Regular", size: 18))
                        .foregroundColor(
                            isSelected ? .white :
                            day.isFuture ? DayflowColors.textMuted.opacity(0.22) :
                            isToday ? DayflowColors.accent :
                            DayflowColors.textPrimary
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(day.isFuture)
            .pointingHandCursor()
        }
    }
}

private struct InlineDatePicker: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    let onSelect: (Date) -> Void

    @State private var pickerDate: Date

    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>, onSelect: @escaping (Date) -> Void) {
        _selectedDate = selectedDate
        _isPresented = isPresented
        self.onSelect = onSelect
        _pickerDate = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 8) {
            DatePicker("", selection: $pickerDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "nl_NL"))
                .labelsHidden()
                .onChange(of: pickerDate) { _, newDate in
                    onSelect(newDate)
                    isPresented = false
                }

            Button("Vandaag") {
                onSelect(Date())
                isPresented = false
            }
            .buttonStyle(.plain)
            .foregroundColor(DayflowColors.accent)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .frame(width: 300)
    }
}
