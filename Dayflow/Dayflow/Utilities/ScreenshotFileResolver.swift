import Foundation

/// Resolves screenshot file paths when the exact filename doesn't exist on disk.
///
/// DayflowDev and the original Dayflow app may capture screenshots independently with
/// slightly different timestamps. When they share a recordings directory (via symlink),
/// the database may reference a file that doesn't exist because it was captured by the
/// other app variant. This resolver finds the closest matching file in the same directory.
enum ScreenshotFileResolver {

    /// Cache: resolved DB path → actual file URL.
    private static let resolvedCache = NSCache<NSString, NSURL>()

    /// Cache: directory path → sorted array of filenames (strings only, memory efficient).
    private static var directoryCache: [String: [String]] = [:]
    private static let lock = NSLock()

    /// Given a URL whose file doesn't exist, find the closest file with a similar
    /// timestamp in the same directory.
    ///
    /// Filename format: `yyyyMMdd_HHmmssSSS.jpg`
    /// Strategy: match on `yyyyMMdd_HHmm` (minute prefix) then pick the first match.
    static func resolve(_ url: URL) -> URL? {
        let key = url.path as NSString
        if let cached = resolvedCache.object(forKey: key) {
            return cached as URL
        }

        let directory = url.deletingLastPathComponent()
        let dirPath = directory.path
        let filename = (url.lastPathComponent as NSString).deletingPathExtension
        // yyyyMMdd_HHmmssSSS = 18 chars; we need at least yyyyMMdd_HHmm = 13 chars
        guard filename.count >= 13 else { return nil }
        let minutePrefix = String(filename.prefix(13)) // e.g. "20260303_2217"

        // Get or build cached sorted filenames for this directory
        let filenames = cachedFilenames(for: dirPath)
        guard !filenames.isEmpty else { return nil }

        // Binary search for the target prefix range, then pick the closest file
        let target = url.lastPathComponent
        guard let matchIndex = filenames.firstIndex(where: { $0.hasPrefix(minutePrefix) }) else {
            return nil
        }

        // Find the closest match within the minute window
        var bestMatch: String?
        var bestDistance = Int.max
        for i in matchIndex..<filenames.count {
            let name = filenames[i]
            guard name.hasPrefix(minutePrefix) else { break }
            let dist = abs(name.compare(target).rawValue)
            if dist < bestDistance {
                bestDistance = dist
                bestMatch = name
            }
        }

        guard let match = bestMatch else { return nil }
        let resolved = directory.appendingPathComponent(match)
        resolvedCache.setObject(resolved as NSURL, forKey: key)
        return resolved
    }

    private static func cachedFilenames(for dirPath: String) -> [String] {
        lock.lock()
        defer { lock.unlock() }

        if let cached = directoryCache[dirPath] {
            return cached
        }

        let dirURL = URL(fileURLWithPath: dirPath)
        guard let entries = try? FileManager.default.contentsOfDirectory(
            at: dirURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            // Don't cache failures — allow retry on next call
            return []
        }

        let names = entries
            .filter { $0.pathExtension == "jpg" }
            .map(\.lastPathComponent)
            .sorted()

        directoryCache[dirPath] = names
        return names
    }
}
