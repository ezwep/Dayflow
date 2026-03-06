//
//  TimelineDataModels.swift
//  Dayflow
//
//  Data models for the new UI timeline components
//

import Foundation
import SwiftUI


/// Represents an activity in the timeline view
struct TimelineActivity: Identifiable {
    let id: String
    let recordId: Int64?
    let batchId: Int64? // Tracks source batch for retry functionality
    let startTime: Date
    let endTime: Date
    let title: String
    let summary: String
    let detailedSummary: String
    let category: String
    let subcategory: String
    let distractions: [Distraction]?
    let videoSummaryURL: String?
    let screenshot: NSImage?
    let appSites: AppSites?
    let isBackupGenerated: Bool?

    static func stableId(recordId: Int64?, batchId: Int64?, startTime: Date, endTime: Date, title: String, category: String, subcategory: String) -> String {
        if let recordId {
            return "record:\(recordId)"
        }
        let batchPart = batchId.map { "batch:\($0)" } ?? "batch:unknown"
        let startMs = Int64((startTime.timeIntervalSince1970 * 1000).rounded())
        let endMs = Int64((endTime.timeIntervalSince1970 * 1000).rounded())
        let contentHash = stableHash("\(title)|\(category)|\(subcategory)")
        return "\(batchPart)-\(startMs)-\(endMs)-\(contentHash)"
    }

    private static func stableHash(_ input: String) -> String {
        var hash: UInt64 = 5381
        for byte in input.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return String(hash, radix: 36)
    }

    func withCategory(_ newCategory: String) -> TimelineActivity {
        TimelineActivity(
            id: id,
            recordId: recordId,
            batchId: batchId,
            startTime: startTime,
            endTime: endTime,
            title: title,
            summary: summary,
            detailedSummary: detailedSummary,
            category: newCategory,
            subcategory: subcategory,
            distractions: distractions,
            videoSummaryURL: videoSummaryURL,
            screenshot: screenshot,
            appSites: appSites,
            isBackupGenerated: isBackupGenerated
        )
    }

    func withVideoSummaryURL(_ newVideoSummaryURL: String?) -> TimelineActivity {
        TimelineActivity(
            id: id,
            recordId: recordId,
            batchId: batchId,
            startTime: startTime,
            endTime: endTime,
            title: title,
            summary: summary,
            detailedSummary: detailedSummary,
            category: category,
            subcategory: subcategory,
            distractions: distractions,
            videoSummaryURL: newVideoSummaryURL,
            screenshot: screenshot,
            appSites: appSites,
            isBackupGenerated: isBackupGenerated
        )
    }
}


/// Sheet view for selecting a date
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    @State private var pickerDate: Date

    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        _selectedDate = selectedDate
        _isPresented = isPresented
        _pickerDate = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Ga naar datum")
                    .font(.custom("Nunito", size: 15).weight(.semibold))
                    .foregroundColor(DayflowColors.textPrimary)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(DayflowColors.textMuted.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                .pointingHandCursor()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()
                .background(DayflowColors.textMuted.opacity(0.15))

            // Kalender — sluit automatisch bij datumkeuze
            DatePicker(
                "",
                selection: $pickerDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "nl_NL"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .onChange(of: pickerDate) { _, newDate in
                selectedDate = newDate
                isPresented = false
            }

            // Vandaag-knop
            Button {
                selectedDate = Date()
                isPresented = false
            } label: {
                Text("Vandaag")
                    .font(.custom("Nunito", size: 13).weight(.medium))
                    .foregroundColor(DayflowColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(DayflowColors.accent.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .pointingHandCursor()
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 320)
        .background(DayflowColors.surface)
    }
}
