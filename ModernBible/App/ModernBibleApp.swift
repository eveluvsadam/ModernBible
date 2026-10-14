import SwiftUI

@main
struct ModernBibleApp: App {

    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var localizationManager = LocalizationManager.shared

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.locale, localizationManager.currentLocale)
                .preferredColorScheme(themeManager.colorScheme)
                .tint(themeManager.accentColor)
        }
    }
}

/// Decides whether to show onboarding or the main app.
struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(onFinished: { hasCompletedOnboarding = true })
            }
        }
        .animation(.easeInOut, value: hasCompletedOnboarding)
    }
}
