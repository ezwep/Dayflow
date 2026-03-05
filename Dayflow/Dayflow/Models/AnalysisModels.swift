//
//  AnalysisModels.swift
//  Dayflow
//
//  Created on 5/1/2025.
//

import Foundation

/// Represents a recording chunk from the database (legacy - video-based)
struct RecordingChunk: Codable {
    let id: Int64
    let startTs: Int
    let endTs: Int
    let fileUrl: String
    let status: String

    var duration: TimeInterval {
        TimeInterval(endTs - startTs)
    }
}

/// Represents a screenshot capture from the database (new - replaces video chunks)
struct Screenshot: Codable, Sendable {
    let id: Int64
    let capturedAt: Int          // Unix timestamp (instant of capture)
    let filePath: String
    let fileSize: Int64?
    let isDeleted: Bool

    var fileURL: URL {
        let url = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        // Fallback: DayflowDev and Dayflow may capture screenshots with slightly
        // different millisecond timestamps. When a symlink shares the recordings
        // directory, the DB path may not match the actual file. Try to find the
        // closest file with the same second-level prefix (yyyyMMdd_HHmmss).
        return ScreenshotFileResolver.resolve(url) ?? url
    }

    var capturedDate: Date {
        Date(timeIntervalSince1970: TimeInterval(capturedAt))
    }
}
