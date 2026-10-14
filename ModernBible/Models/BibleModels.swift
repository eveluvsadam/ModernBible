import Foundation

/// A Bible translation available in the app (bundled or downloadable).
struct Translation: Identifiable, Codable, Hashable {
    let id: String            // e.g. "kjv", "lsg", "htcv"
    let displayName: String
    let languageCode: String  // "en", "fr", "ht"
    let isBundled: Bool
    let isDownloaded: Bool

    static let kjv = Translation(id: "kjv", displayName: "King James Version", languageCode: "en", isBundled: true, isDownloaded: true)
    static let lsg = Translation(id: "lsg", displayName: "Louis Segond 1910", languageCode: "fr", isBundled: true, isDownloaded: true)
    static let htcv = Translation(id: "htcv", displayName: "Bib la (Kreyòl Ayisyen)", languageCode: "ht", isBundled: true, isDownloaded: true)
}

struct Book: Identifiable, Codable, Hashable {
    let id: Int                // 1...66
    let name: String
    let abbreviation: String
    let testament: Testament
    let chapterCount: Int
}

enum Testament: String, Codable {
    case old = "OT"
    case new = "NT"
}

struct Verse: Identifiable, Codable, Hashable {
    var id: String { "\(bookId).\(chapter).\(verse)" }
    let bookId: Int
    let chapter: Int
    let verse: Int
    let text: String
}

struct VerseReference: Codable, Hashable, Equatable {
    let bookId: Int
    let chapter: Int
    let verse: Int

    var displayString: String {
        // Resolved to a localized book name by the caller using BookNameProviding.
        "\(bookId) \(chapter):\(verse)"
    }
}

struct SearchResult: Identifiable {
    var id: String { verse.id + translationId }
    let verse: Verse
    let translationId: String
    let bookName: String
}

/// Highlight color presets used across the app.
enum HighlightColor: String, CaseIterable, Codable, Identifiable {
    case yellow, green, blue, pink, purple

    var id: String { rawValue }

    var hex: String {
        switch self {
        case .yellow: return "#FDE68A"
        case .green:  return "#BBF7D0"
        case .blue:   return "#BFDBFE"
        case .pink:   return "#FBCFE8"
        case .purple: return "#E9D5FF"
        }
    }
}

struct ReadingPlanDefinition: Identifiable, Codable {
    let id: String
    let title: String
    let descriptionText: String
    let totalDays: Int
    let readingsByDay: [Int: [VerseRangeReference]]  // day index -> passages to read
}

struct VerseRangeReference: Codable, Hashable {
    let bookId: Int
    let chapterStart: Int
    let chapterEnd: Int
}
