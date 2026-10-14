import Foundation
import Combine

/// Lets the user override the app's language independent of the device's system language
/// (Settings → Language: English / Français / Kreyòl Ayisyen).
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "appLanguageOverride"

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let lang = AppLanguage(rawValue: raw) {
            language = lang
        } else {
            // Default to device language if it's one we support, else English.
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            language = AppLanguage(rawValue: deviceLanguage) ?? .english
        }
    }

    var currentLocale: Locale {
        Locale(identifier: language.rawValue)
    }

    /// Looks up a localized string from the *app-selected* language bundle, not the system locale —
    /// this is what makes the in-app language switcher actually work regardless of iOS Settings.
    func string(_ key: String, comment: String = "") -> String {
        guard
            let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return NSLocalizedString(key, comment: comment)
        }
        return NSLocalizedString(key, bundle: bundle, comment: comment)
    }
}

/// Convenience so views can write `L("home.title")` instead of the full manager call.
func L(_ key: String) -> String {
    LocalizationManager.shared.string(key)
}
