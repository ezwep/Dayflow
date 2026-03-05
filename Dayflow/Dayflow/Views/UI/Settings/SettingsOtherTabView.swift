import SwiftUI

struct SettingsOtherTabView: View {
    @ObservedObject var viewModel: OtherSettingsViewModel
    @ObservedObject var launchAtLoginManager: LaunchAtLoginManager
    @FocusState private var isOutputLanguageFocused: Bool
    @State private var activeExportDatePicker: ExportDatePicker?


    private enum ExportDatePicker {
        case start
        case end
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            timelineExportCard

            SettingsCard(title: "App preferences", subtitle: "General toggles and telemetry settings") {
                VStack(alignment: .leading, spacing: 14) {
                    Toggle(isOn: Binding(
                        get: { launchAtLoginManager.isEnabled },
                        set: { launchAtLoginManager.setEnabled($0) }
                    )) {
                        Text("Launch Dayflow at login")
                            .font(.custom("Nunito", size: 13))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.7))
                    }
                    .toggleStyle(.switch)
                    .pointingHandCursor()

                    Text("Keeps the menu bar controller running right after you sign in so capture can resume instantly.")
                        .font(.custom("Nunito", size: 11.5))
                        .foregroundColor(DayflowColors.textMuted)

                    Toggle(isOn: $viewModel.analyticsEnabled) {
                        Text("Share crash reports and anonymous usage data")
                            .font(.custom("Nunito", size: 13))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.7))
                    }
                    .toggleStyle(.switch)
                    .pointingHandCursor()

                    Toggle(isOn: $viewModel.showDockIcon) {
                        Text("Show Dock icon")
                            .font(.custom("Nunito", size: 13))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.7))
                    }
                    .toggleStyle(.switch)
                    .pointingHandCursor()

                    Text("When off, Dayflow runs as a menu bar–only app.")
                        .font(.custom("Nunito", size: 11.5))
                        .foregroundColor(DayflowColors.textMuted)

                    Toggle(isOn: $viewModel.showTimelineAppIcons) {
                        Text("Show app/website icons in timeline")
                            .font(.custom("Nunito", size: 13))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.7))
                    }
                    .toggleStyle(.switch)
                    .pointingHandCursor()

                    Text("When off, timeline cards won't show app or website icons.")
                        .font(.custom("Nunito", size: 11.5))
                        .foregroundColor(DayflowColors.textMuted)

                    Toggle(isOn: $viewModel.use24HourTime) {
                        Text("Use 24-hour time format")
                            .font(.custom("Nunito", size: 13))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.7))
                    }
                    .toggleStyle(.switch)
                    .pointingHandCursor()

                    Text("Displays times as 14:30 instead of 2:30 PM throughout the app.")
                        .font(.custom("Nunito", size: 11.5))
                        .foregroundColor(DayflowColors.textMuted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appearance")
                            .font(.custom("Nunito", size: 13).weight(.semibold))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.85))

                        Picker("", selection: $viewModel.appearance) {
                            Text("Dark").tag("dark")
                            Text("Light").tag("light")
                            Text("System").tag("system")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 240)

                        Text("Choose between dark mode, light mode, or follow your system setting.")
                            .font(.custom("Nunito", size: 11.5))
                            .foregroundColor(DayflowColors.textMuted)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color theme")
                            .font(.custom("Nunito", size: 13).weight(.semibold))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.85))

                        HStack(spacing: 12) {
                            ForEach(DayflowThemeId.allCases) { themeId in
                                themeSwatchButton(themeId: themeId)
                            }
                        }

                        Text("Changes the accent colors throughout the app.")
                            .font(.custom("Nunito", size: 11.5))
                            .foregroundColor(DayflowColors.textMuted)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Inactivity threshold")
                            .font(.custom("Nunito", size: 13).weight(.semibold))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.85))
                        HStack(spacing: 10) {
                            Button(action: {
                                if viewModel.idleThresholdMinutes > 1 {
                                    viewModel.idleThresholdMinutes -= 1
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(DayflowColors.textPrimary.opacity(0.7))
                                    .frame(width: 28, height: 28)
                                    .background(DayflowColors.surface)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(DayflowColors.border, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())

                            Text("\(viewModel.idleThresholdMinutes) minute\(viewModel.idleThresholdMinutes == 1 ? "" : "s")")
                                .font(.custom("Nunito", size: 14).weight(.semibold))
                                .foregroundColor(DayflowColors.textPrimary.opacity(0.85))
                                .frame(minWidth: 80)

                            Button(action: {
                                if viewModel.idleThresholdMinutes < 60 {
                                    viewModel.idleThresholdMinutes += 1
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(DayflowColors.textPrimary.opacity(0.7))
                                    .frame(width: 28, height: 28)
                                    .background(DayflowColors.surface)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(DayflowColors.border, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Text("After this period of inactivity, a popup will ask what you were doing.")
                            .font(.custom("Nunito", size: 11.5))
                            .foregroundColor(DayflowColors.textMuted)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Output language override")
                            .font(.custom("Nunito", size: 13))
                            .foregroundColor(DayflowColors.textPrimary.opacity(0.7))
                        HStack(spacing: 10) {
                            TextField("English", text: $viewModel.outputLanguageOverride)
                                .textFieldStyle(.roundedBorder)
                                .disableAutocorrection(true)
                                .frame(maxWidth: 220)
                                .focused($isOutputLanguageFocused)
                                .onChange(of: viewModel.outputLanguageOverride) {
                                    viewModel.markOutputLanguageOverrideEdited()
                                }
                            DayflowSurfaceButton(
                                action: {
                                    viewModel.saveOutputLanguageOverride()
                                    isOutputLanguageFocused = false
                                },
                                content: {
                                    HStack(spacing: 6) {
                                        Image(systemName: viewModel.isOutputLanguageOverrideSaved ? "checkmark" : "square.and.arrow.down")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text(viewModel.isOutputLanguageOverrideSaved ? "Saved" : "Save")
                                            .font(.custom("Nunito", size: 12))
                                    }
                                    .padding(.horizontal, 2)
                                },
                                background: DayflowColors.surface,
                                foreground: DayflowColors.accent,
                                borderColor: DayflowColors.accent.opacity(0.4),
                                cornerRadius: 8,
                                horizontalPadding: 12,
                                verticalPadding: 7,
                                showOverlayStroke: true
                            )
                            .disabled(viewModel.isOutputLanguageOverrideSaved)
                            DayflowSurfaceButton(
                                action: {
                                    viewModel.resetOutputLanguageOverride()
                                    isOutputLanguageFocused = false
                                },
                                content: {
                                    Text("Reset")
                                        .font(.custom("Nunito", size: 11))
                                },
                                background: DayflowColors.surface,
                                foreground: DayflowColors.accent,
                                borderColor: DayflowColors.accent.opacity(0.4),
                                cornerRadius: 8,
                                horizontalPadding: 10,
                                verticalPadding: 6,
                                showOverlayStroke: true
                            )
                        }
                        Text("The default language is English. You can specify any language here (examples: English, 简体中文, Español, 日本語, 한국어, Français).")
                            .font(.custom("Nunito", size: 11.5))
                            .foregroundColor(DayflowColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text("Dayflow Dev v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))")
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(DayflowColors.textMuted)
                }
            }


        }
    }

    private var timelineExportCard: some View {
        SettingsCard(title: "Export timeline", subtitle: "Download a Markdown export for any date range") {
            let rangeInvalid = timelineDisplayDate(from: viewModel.exportStartDate) > timelineDisplayDate(from: viewModel.exportEndDate)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .bottom, spacing: 12) {
                    datePillField(
                        label: "From",
                        date: viewModel.exportStartDate,
                        isExpanded: activeExportDatePicker == .start,
                        accessibilityLabel: "Export start date",
                        onTap: {
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                                activeExportDatePicker = activeExportDatePicker == .start ? nil : .start

                            }
                        }
                    )

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DayflowColors.textMuted)
                        .padding(.bottom, 12)

                    datePillField(
                        label: "To",
                        date: viewModel.exportEndDate,
                        isExpanded: activeExportDatePicker == .end,
                        accessibilityLabel: "Export end date",
                        onTap: {
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                                activeExportDatePicker = activeExportDatePicker == .end ? nil : .end

                            }
                        }
                    )
                }

                if let activeExportDatePicker {
                    inlineCalendarField(
                        label: activeExportDatePicker == .start ? "Start date" : "End date",
                        date: exportDateBinding(for: activeExportDatePicker),
                        onDateSelected: {
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                                self.activeExportDatePicker = nil
                            }
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Text("Includes titles, summaries, and details for each card.")
                    .font(.custom("Nunito", size: 11.5))
                    .foregroundColor(DayflowColors.textMuted)

                HStack(spacing: 10) {
                    DayflowSurfaceButton(
                        action: viewModel.exportTimelineRange,
                        content: {
                            HStack(spacing: 8) {
                                if viewModel.isExportingTimelineRange {
                                    ProgressView().scaleEffect(0.75)
                                } else {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                Text(viewModel.isExportingTimelineRange ? "Exporting…" : "Export as Markdown")
                                    .font(.custom("Nunito", size: 13))
                                    .fontWeight(.semibold)
                            }
                            .frame(minWidth: 150)
                        },
                        background: DayflowColors.accent,
                        foreground: .white,
                        borderColor: .clear,
                        cornerRadius: 8,
                        horizontalPadding: 20,
                        verticalPadding: 10,
                        showOverlayStroke: true
                    )
                    .disabled(viewModel.isExportingTimelineRange || rangeInvalid)

                    if rangeInvalid {
                        Text("Start date must be on or before end date.")
                            .font(.custom("Nunito", size: 12))
                            .foregroundColor(DayflowColors.error)
                    }
                }

                if let message = viewModel.exportStatusMessage {
                    Text(message)
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(DayflowColors.success)
                }

                if let error = viewModel.exportErrorMessage {
                    Text(error)
                        .font(.custom("Nunito", size: 12))
                        .foregroundColor(DayflowColors.error)
                }
            }
            .padding(.top, 4)
        }
    }

    private func formattedTimelineDate(_ date: Date) -> String {
        Self.dateLabelFormatter.string(from: timelineDisplayDate(from: date))
    }

    private func exportDateBinding(for picker: ExportDatePicker) -> Binding<Date> {
        switch picker {
        case .start:
            return $viewModel.exportStartDate
        case .end:
            return $viewModel.exportEndDate
        }
    }

    private func datePillField(
        label: String,
        date: Date,
        isExpanded: Bool,
        accessibilityLabel: String,
        disabled: Bool = false,
        onTap: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.custom("Nunito", size: 11.5))
                .foregroundColor(DayflowColors.textMuted)

            Button {
                guard !disabled else { return }
                onTap()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DayflowColors.accent.opacity(disabled ? 0.4 : 0.75))

                    Text(formattedTimelineDate(date))
                        .font(.custom("Nunito", size: 14))
                        .foregroundColor(DayflowColors.textPrimary.opacity(disabled ? 0.35 : 0.82))

                    Spacer(minLength: 4)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(DayflowColors.textMuted.opacity(disabled ? 0.2 : 0.35))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .frame(minWidth: 176)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(DayflowColors.surface.opacity(disabled ? 0.45 : 0.88))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    isExpanded
                                        ? DayflowColors.accent
                                        : DayflowColors.accent.opacity(0.4),
                                    lineWidth: 1.2
                                )
                        )
                )
                .shadow(color: .black.opacity(disabled ? 0 : 0.05), radius: 6, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            .accessibilityLabel(Text(accessibilityLabel))
        }
    }

    private func inlineCalendarField(
        label: String,
        date: Binding<Date>,
        disabled: Bool = false,
        onDateSelected: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("Nunito", size: 11.5))
                .foregroundColor(DayflowColors.textMuted)

            DatePicker("", selection: date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .onChange(of: date.wrappedValue) { _, _ in
                    onDateSelected()
                }
                .frame(maxWidth: 290, alignment: .leading)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DayflowColors.surface.opacity(disabled ? 0.45 : 0.82))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DayflowColors.accent.opacity(0.4), lineWidth: 1.2)
                        )
                )
                .shadow(color: .black.opacity(disabled ? 0 : 0.04), radius: 7, x: 0, y: 2)
                .disabled(disabled)
        }
        .opacity(disabled ? 0.7 : 1)
    }

    private func themeSwatchButton(themeId: DayflowThemeId) -> some View {
        let isSelected = viewModel.theme == themeId.rawValue
        return Button {
            viewModel.theme = themeId.rawValue
        } label: {
            VStack(spacing: 6) {
                Circle()
                    .fill(Color(nsColor: themeId.swatchColor))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected
                                    ? Color(nsColor: themeId.swatchColor).opacity(0.5)
                                    : DayflowColors.border,
                                lineWidth: 1
                            )
                            .padding(-2)
                    )
                    .shadow(
                        color: isSelected
                            ? Color(nsColor: themeId.swatchColor).opacity(0.4)
                            : .clear,
                        radius: 6, x: 0, y: 2
                    )

                Text(themeId.displayName)
                    .font(.custom("Nunito", size: 11))
                    .foregroundColor(
                        isSelected
                            ? DayflowColors.textPrimary
                            : DayflowColors.textMuted
                    )
            }
        }
        .buttonStyle(.plain)
        .pointingHandCursor()
    }

    private static let dateLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
        return formatter
    }()
}
