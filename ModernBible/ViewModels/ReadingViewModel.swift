import Foundation
import Combine

@MainActor
final class ReadingViewModel: ObservableObject {
    @Published var verses: [Verse] = []
    @Published var book: Book?
    @Published var isLoading = false

    private let dataService: BibleDataProviding
    private let userData: UserDataService

    init(dataService: BibleDataProviding = BibleDataService.shared, userData: UserDataService = .shared) {
        self.dataService = dataService
        self.userData = userData
    }

    func load(bookId: Int, chapter: Int, translation: Translation) {
        isLoading = true
        book = dataService.books(for: translation).first { $0.id == bookId }
        verses = dataService.chapter(bookId: bookId, chapter: chapter, translation: translation)
        isLoading = false
    }

    func isBookmarked(_ verse: Verse, translation: Translation) -> Bool {
        userData.isBookmarked(translationId: translation.id, reference: verse.reference)
    }

    func toggleBookmark(_ verse: Verse, translation: Translation) {
        userData.toggleBookmark(translationId: translation.id, reference: verse.reference)
        objectWillChange.send()
    }

    func highlightColor(_ verse: Verse, translation: Translation) -> HighlightColor? {
        userData.highlight(translationId: translation.id, reference: verse.reference)
    }

    func setHighlight(_ color: HighlightColor?, for verse: Verse, translation: Translation) {
        userData.setHighlight(color, translationId: translation.id, reference: verse.reference)
        objectWillChange.send()
    }
}

extension Verse {
    var reference: VerseReference { VerseReference(bookId: bookId, chapter: chapter, verse: verse) }
}
