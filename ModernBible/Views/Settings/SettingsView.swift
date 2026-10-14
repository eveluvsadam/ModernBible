import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var localizationManager: LocalizationManager

    @State private var notificationsEnabled = false
    @State private var notificationTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? Date()
    @State private var cloudSyncEnabled = false

    var body: some View {
        Form {
            Section(L("settings.language")) {
                Picker(L("settings.language"), selection: $localizationManager.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section(L("settings.appearance")) {
                Picker(L("settings.theme"), selection: $themeManager.theme) {
                    Text(L("settings.theme.system")).tag(AppTheme.system)
                    Text(L("settings.theme.light")).tag(AppTheme.light)
                    Text(L("settings.theme.dark")).tag(AppTheme.dark)
                }

                VStack(alignment: .leading) {
                    Text(L("settings.font_size"))
                    Slider(value: $themeManager.fontSize, in: 14...26, step: 1) {
                        Text(L("settings.font_size"))
                    }
                    Text("The quick brown fox")
                        .font(.system(size: themeManager.fontSize))
                }

                Picker(L("settings.reading_background"), selection: $themeManager.readingBackground) {
                    ForEach(ThemeManager.backgroundOptions, id: \.self) { option in
                        Text(option.capitalized).tag(option)
                    }
                }
            }

            Section(L("settings.notifications")) {
                Toggle(L("settings.daily_verse"), isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestAuthorization { granted in
                                if !granted {
                                    Task { @MainActor in notificationsEnabled = false }
                                }
                            }
                        } else {
                            NotificationService.shared.cancelDailyVerse()
                        }
                    }
                if notificationsEnabled {
                    DatePicker(L("settings.notification_time"), selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .onChange(of: notificationTime) { _, newTime in
                            NotificationService.shared.scheduleDailyVerse(at: newTime, verseText: "", verseReference: "")
                        }
                }
            }

            Section(L("settings.sync")) {
                Toggle(L("settings.cloud_sync"), isOn: $cloudSyncEnabled)
                Text(L("settings.cloud_sync.footnote"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent(L("settings.version"), value: Bundle.main.appVersionString)
            }
        }
        .navigationTitle(L("more.settings"))
    }
}

extension Bundle {
    var appVersionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager.shared)
}
