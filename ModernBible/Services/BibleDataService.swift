import Foundation

protocol BibleDataProviding {
    func books(for translation: Translation) -> [Book]
    func chapter(bookId: Int, chapter: Int, translation: Translation) -> [Verse]
    func search(query: String, translation: Translation) -> [SearchResult]
}

/// Loads bundled per-translation JSON (Resources/BibleData/*.json) into memory and serves
/// reads from there. This ships real, working sample data out of the box with zero external
/// dependencies (no SPM package, no libsqlite3 linking required).
///
/// IMPORTANT: the bundled JSON currently contains a small set of well-known sample verses per
/// translation (Genesis 1, Psalm 23, John 3 for English/French) so the app is functional and
/// demoable immediately. The Haitian Creole file ships with explicit `[PLACEHOLDER]` verse text —
/// see docs/DATA_SOURCES.md for licensing-safe sources to replace all three with full translations.
///
/// This in-memory approach comfortably scales to a full single translation (~31,000 verses,
/// a few MB of JSON) with instant chapter loads and a linear-scan search fast enough for
/// search-as-you-type. If you later want multi-translation full-text indexing at larger scale,
/// swap this out for GRDB.swift + SQLite FTS5 as described in docs/DATABASE_STRUCTURE.md —
/// the `BibleDataProviding` protocol means no call site elsewhere in the app needs to change.
final class BibleDataService: BibleDataProviding {
    static let shared = BibleDataService()

    private struct TranslationFile: Decodable {
        let books: [Book]
        let verses: [Verse]
    }

    private var cache: [String: TranslationFile] = [:]

    private func file(for translation: Translation) -> TranslationFile {
        if let cached = cache[translation.id] { return cached }

        guard
            let url = Bundle.main.url(forResource: translation.id, withExtension: "json", subdirectory: nil)
                ?? Bundle.main.url(forResource: translation.id, withExtension: "json", subdirectory: "BibleData"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(TranslationFile.self, from: data)
        else {
            let empty = TranslationFile(books: [], verses: [])
            cache[translation.id] = empty
            return empty
        }

        cache[translation.id] = decoded
        return decoded
    }

    func books(for translation: Translation) -> [Book] {
        file(for: translation).books
    }

    func chapter(bookId: Int, chapter: Int, translation: Translation) -> [Verse] {
        file(for: translation).verses
            .filter { $0.bookId == bookId && $0.chapter == chapter }
            .sorted { $0.verse < $1.verse }
    }

    func search(query: String, translation: Translation) -> [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let translationFile = file(for: translation)
        let bookNames = Dictionary(uniqueKeysWithValues: translationFile.books.map { ($0.id, $0.name) })

        return translationFile.verses
            .filter { $0.text.range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
            .prefix(100)
            .map { verse in
                SearchResult(verse: verse, translationId: translation.id, bookName: bookNames[verse.bookId] ?? "")
            }
    }
}
