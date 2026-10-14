import Testing
@testable import ModernBible

struct ModernBibleTests {

    @Test func chapterLoadReturnsSortedVerses() async throws {
        let verses = BibleDataService.shared.chapter(bookId: 1, chapter: 1, translation: .kjv)
        #expect(verses == verses.sorted { $0.verse < $1.verse })
    }

    @Test func searchIsCaseInsensitive() async throws {
        let results = BibleDataService.shared.search(query: "god", translation: .kjv)
        #expect(!results.isEmpty)
    }
}

