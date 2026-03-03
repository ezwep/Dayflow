import Foundation

enum TimeFormatPreferences {
    private static let defaults = UserDefaults.standard
    private static let use24HourKey = "use24HourTimeFormat"

    static var use24Hour: Bool {
        get { defaults.bool(forKey: use24HourKey) }
        set { defaults.set(newValue, forKey: use24HourKey) }
    }

    /// The date format string for displaying time to the user.
    /// Returns "H:mm" for 24-hour or "h:mm a" for 12-hour.
    static var displayTimeFormat: String {
        use24Hour ? "H:mm" : "h:mm a"
    }

    /// Updates an existing DateFormatter's dateFormat to match the current preference.
    static func applyDisplayFormat(to formatter: DateFormatter) {
        formatter.dateFormat = displayTimeFormat
    }

    /// Formats an hour integer (0-23 or 24-27 for next-day hours) as a time label.
    /// Used by the canvas timeline hour labels.
    static func formatHourLabel(_ hour: Int) -> String {
        let normalizedHour = hour >= 24 ? hour - 24 : hour
        if use24Hour {
            return String(format: "%d:00", normalizedHour)
        } else {
            let adjustedHour = normalizedHour > 12 ? normalizedHour - 12 : (normalizedHour == 0 ? 12 : normalizedHour)
            let period = normalizedHour >= 12 ? "PM" : "AM"
            return "\(adjustedHour):00 \(period)"
        }
    }
}
