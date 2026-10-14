import Foundation
import Combine

/// App-wide reading position + selected translation. Injected once at the root.
final class AppState: ObservableObject {
    @Published var currentTranslation: Translation = .kjv
    @Published var currentBookId: Int = 43       // John
    @Published var currentChapter: Int = 3

    /// Updates position and records it into recent history.
    func navigate(to bookId: Int, chapter: Int, verse: Int? = nil, recentsService: RecentsProviding = RecentsService.shared) {
        currentBookId = bookId
        currentChapter = chapter
        if let verse {
            recentsService.recordView(translationId: currentTranslation.id, bookId: bookId, chapter: chapter, verse: verse)
        }
    }
}
