import AppKit
import Combine
import CoreGraphics

@MainActor
final class InactivityMonitor: ObservableObject {
    static let shared = InactivityMonitor()

    // Published so views can react when an idle reset is pending
    @Published var pendingReset: Bool = false

    /// Timestamp when the user became idle (last interaction before threshold was exceeded)
    @Published var idleStartedAt: Date?
    /// Timestamp when the user returned from idle
    @Published var idleEndedAt: Date?

    // Config
    private let secondsOverrideKey = "idleResetSecondsOverride"
    private let legacyMinutesKey = "idleResetMinutes"
    private let defaultThresholdSeconds: TimeInterval = 5 * 60

    var thresholdSeconds: TimeInterval {
        let override = UserDefaults.standard.double(forKey: secondsOverrideKey)
        if override > 0 { return override }

        let legacyMinutes = UserDefaults.standard.integer(forKey: legacyMinutesKey)
        if legacyMinutes > 0 {
            return TimeInterval(legacyMinutes * 60)
        }

        return defaultThresholdSeconds
    }

    // State
    /// Whether we've detected the user is currently idle (system-wide)
    private var isIdle: Bool = false
    /// When we first detected the user entered idle state
    private var idleEnteredAt: Date?
    /// Prevents re-triggering too quickly after a reset
    private var lastResetAt: Date? = nil
    /// Timer that periodically checks system-wide idle time
    private var checkTimer: Timer?
    /// App lifecycle observers
    private var observers: [NSObjectProtocol] = []

    private init() {}

    func start() {
        setupAppLifecycleObservers()
        startTimer()
    }

    func stop() {
        stopTimer()
        removeObservers()
    }

    func markHandledIfPending() {
        if pendingReset {
            pendingReset = false
        }
    }

    // MARK: - System-wide idle detection

    /// Returns the system-wide idle time in seconds.
    /// Checks multiple HID event types and returns the smallest value
    /// (i.e. how recently the user did *anything* on the Mac).
    private func systemIdleSeconds() -> TimeInterval {
        let mouseMove   = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .mouseMoved)
        let leftDown    = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .leftMouseDown)
        let rightDown   = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .rightMouseDown)
        let keyDown     = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .keyDown)
        let scrollWheel = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .scrollWheel)

        return min(mouseMove, leftDown, rightDown, keyDown, scrollWheel)
    }

    // MARK: - Lifecycle

    private func setupAppLifecycleObservers() {
        removeObservers()

        let center = NotificationCenter.default

        // When app becomes active, do an immediate idle check so the popup
        // appears right when the user switches back to Dayflow.
        let didBecome = center.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkIdle()
            }
        }
        observers.append(didBecome)
    }

    private func removeObservers() {
        let center = NotificationCenter.default
        for observer in observers {
            center.removeObserver(observer)
        }
        observers.removeAll()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        // Poll every 10 seconds. The timer runs even when the app is in the
        // background on macOS, so we catch idle → active transitions quickly.
        checkTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkIdle()
            }
        }
        // Ensure the timer fires in common run-loop modes (e.g. during tracking)
        if let timer = checkTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopTimer() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    // MARK: - Idle check (two-phase: detect idle → detect return)

    private func checkIdle() {
        guard !pendingReset else { return }

        let threshold = thresholdSeconds
        let idleTime = systemIdleSeconds()

        if !isIdle {
            // Phase 1: User was active. Check if they've been idle long enough.
            if idleTime >= threshold {
                isIdle = true
                // The user became idle roughly `idleTime` seconds ago
                idleEnteredAt = Date().addingTimeInterval(-idleTime)
            }
        } else {
            // Phase 2: User was idle. Check if they've come back.
            // "Come back" = any system input within the last 30 seconds.
            if idleTime < 30 {
                isIdle = false

                let now = Date()

                // Don't re-trigger if we already showed a popup recently
                if let lastReset = lastResetAt, now.timeIntervalSince(lastReset) < threshold {
                    idleEnteredAt = nil
                    return
                }

                idleStartedAt = idleEnteredAt
                idleEndedAt = now
                pendingReset = true
                lastResetAt = now
                idleEnteredAt = nil
            }
        }
    }
}
