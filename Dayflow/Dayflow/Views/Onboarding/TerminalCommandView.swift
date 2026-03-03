//
//  TerminalCommandView.swift
//  Dayflow
//
//  Terminal command display with copy functionality
//

import SwiftUI
import AppKit

struct TerminalCommandView: View {
    let title: String
    let subtitle: String
    let command: String
    
    @State private var isCopied = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("Nunito", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(DayflowColors.textPrimary)
            
            Text(subtitle)
                .font(.custom("Nunito", size: 14))
                .foregroundColor(DayflowColors.textMuted)
            
            // Command block with trailing copy button (overlay for tight right alignment)
            ZStack(alignment: .leading) {
                // Command text area
                Text(command)
                    .font(.custom("SF Mono", size: 13))
                    .foregroundColor(DayflowColors.textPrimary)
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .padding(.trailing, 120) // reserve space so text doesn't sit under the button
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay(alignment: .trailing) {
                DayflowSurfaceButton(
                    action: copyCommand,
                    content: {
                        HStack(spacing: 6) {
                            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 12, weight: .medium))
                            Text(isCopied ? "Copied" : "Copy")
                                .font(.custom("Nunito", size: 13))
                                .fontWeight(.medium)
                        }
                        .foregroundColor(isCopied ? DayflowColors.success : DayflowColors.textPrimary)
                    },
                    background: DayflowColors.surface,
                    foreground: DayflowColors.textPrimary,
                    borderColor: DayflowColors.borderSubtle,
                    cornerRadius: 6,
                    horizontalPadding: 14,
                    verticalPadding: 10,
                    showShadow: false
                )
                .padding(.trailing, 6)
                .padding(.vertical, 6)
            }
            .background(DayflowColors.surface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(DayflowColors.borderSubtle, lineWidth: 1)
            )
        }
    }
    
    private func copyCommand() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
        
        // Track copy (without sending command content)
        AnalyticsService.shared.capture("terminal_command_copied", [
            "title": title
        ])

        withAnimation(.easeInOut(duration: 0.2)) {
            isCopied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isCopied = false
            }
        }
    }
}
