import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [SearchResult] = []

    private let dataService: BibleDataProviding
    private var searchTask: Task<Void, Never>?

    init(dataService: BibleDataProviding = BibleDataService.shared) {
        self.dataService = dataService
    }

    /// Debounced so fast typing doesn't hammer the FTS query on every keystroke.
    func onQueryChanged(_ newValue: String, translation: Translation) {
        searchTask?.cancel()
        guard !newValue.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard !Task.isCancelled else { return }
            let found = dataService.search(query: newValue, translation: translation)
            await MainActor.run { self.results = found }
        }
    }
}
