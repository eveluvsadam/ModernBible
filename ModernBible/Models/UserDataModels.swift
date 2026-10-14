import Foundation

// These mirror the Core Data entities described in docs/DATABASE_STRUCTURE.md.
// Using plain structs here for the ViewModel-facing layer; PersistenceController
// maps NSManagedObjects to/from these so the rest of the app never touches Core Data directly.

struct Bookmark: Identifiable, Hashable {
    let id: UUID
    let translationId: String
    let reference: VerseReference
    let createdAt: Date
}

struct Highlight: Identifiable, Hashable {
    let id: UUID
    let translationId: String
    let reference: VerseReference
    let color: HighlightColor
    let createdAt: Date
}

struct Note: Identifiable, Hashable {
    let id: UUID
    let translationId: String
    let reference: VerseReference
    var body: String
    let createdAt: Date
    var updatedAt: Date
}

struct RecentVerse: Identifiable, Hashable {
    let id: UUID
    let translationId: String
    let reference: VerseReference
    let viewedAt: Date
}

struct PrayerEntry: Identifiable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var category: PrayerCategory
    var isAnswered: Bool
    let createdAt: Date
    var answeredAt: Date?
}

enum PrayerCategory: String, CaseIterable, Codable, Identifiable {
    case family, health, gratitude, requests, other
    var id: String { rawValue }
}

struct ReadingPlanProgress: Identifiable, Hashable {
    let id: UUID
    let planKey: String
    let title: String
    let totalDays: Int
    let startedAt: Date
    var completedDayIndexes: Set<Int>

    var progressFraction: Double {
        totalDays == 0 ? 0 : Double(completedDayIndexes.count) / Double(totalDays)
    }
}

struct UserSettings: Codable {
    var preferredLanguage: AppLanguage = .english
    var preferredTranslationId: String = Translation.kjv.id
    var fontSize: Double = 17
    var theme: AppTheme = .system
    var readingBackground: String = "default"
    var dailyVerseNotificationEnabled: Bool = false
    var dailyVerseNotificationTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? Date()
    var cloudSyncEnabled: Bool = false
}

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"
    case haitianCreole = "ht"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .french: return "Français"
        case .haitianCreole: return "Kreyòl Ayisyen"
        }
    }
}

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
}
