import SwiftUI

struct ReadingView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = ReadingViewModel()

    @State private var selectedVerseForNote: Verse?
    @State private var showingBookPicker = false

    var body: some View {
        ZStack {
            themeManager.readingBackgroundView()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    ForEach(viewModel.verses) { verse in
                        VerseRow(
                            verse: verse,
                            fontSize: themeManager.fontSize,
                            highlightColor: viewModel.highlightColor(verse, translation: appState.currentTranslation),
                            isBookmarked: viewModel.isBookmarked(verse, translation: appState.currentTranslation),
                            onBookmark: { viewModel.toggleBookmark(verse, translation: appState.currentTranslation) },
                            onHighlight: { color in viewModel.setHighlight(color, for: verse, translation: appState.currentTranslation) },
                            onNote: { selectedVerseForNote = verse },
                            onShare: { shareVerse(verse) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(viewModel.book.map { "\($0.name) \(appState.currentChapter)" } ?? "")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { showingBookPicker = true } label: {
                    Image(systemName: "list.bullet")
                }
                .accessibilityLabel(L("reading.choose_book"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach([Translation.kjv, .lsg, .htcv]) { translation in
                        Button(translation.displayName) {
                            appState.currentTranslation = translation
                            reload()
                        }
                    }
                } label: {
                    Text(appState.currentTranslation.id.uppercased())
                }
            }
        }
        .onAppear(perform: reload)
        .onChange(of: appState.currentChapter) { _, _ in reload() }
        .sheet(item: $selectedVerseForNote) { verse in
            NoteEditorView(verse: verse, translation: appState.currentTranslation)
        }
        .sheet(isPresented: $showingBookPicker) {
            BookChapterPickerView(translation: appState.currentTranslation) { bookId, chapter in
                appState.navigate(to: bookId, chapter: chapter)
                showingBookPicker = false
            }
        }
    }

    private func reload() {
        viewModel.load(bookId: appState.currentBookId, chapter: appState.currentChapter, translation: appState.currentTranslation)
        appState.navigate(to: appState.currentBookId, chapter: appState.currentChapter, verse: 1)
    }

    private func shareVerse(_ verse: Verse) {
        let text = "\(verse.text)\n— \(viewModel.book?.name ?? "") \(verse.chapter):\(verse.verse)"
        let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController?
            .present(activity, animated: true)
    }
}

/// Placeholder sheet for picking a book + chapter. Backed by BibleDataService.books(for:).
struct BookChapterPickerView: View {
    let translation: Translation
    let onSelect: (Int, Int) -> Void
    @State private var books: [Book] = []

    /// New Testament listed first, then Old Testament — matches how most readers navigate day to day.
    private var newTestamentBooks: [Book] { books.filter { $0.testament == .new } }
    private var oldTestamentBooks: [Book] { books.filter { $0.testament == .old } }

    var body: some View {
        NavigationStack {
            List {
                if !newTestamentBooks.isEmpty {
                    Section(L("reading.new_testament")) {
                        ForEach(newTestamentBooks) { book in
                            bookRow(book)
                        }
                    }
                }
                if !oldTestamentBooks.isEmpty {
                    Section(L("reading.old_testament")) {
                        ForEach(oldTestamentBooks) { book in
                            bookRow(book)
                        }
                    }
                }
            }
            .navigationTitle(L("reading.choose_book"))
            .onAppear { books = BibleDataService.shared.books(for: translation) }
        }
    }

    private func bookRow(_ book: Book) -> some View {
        NavigationLink(book.name) {
            List(1...book.chapterCount, id: \.self) { chapter in
                Button("\(chapter)") { onSelect(book.id, chapter) }
            }
            .navigationTitle(book.name)
        }
    }
}

#Preview {
    NavigationStack { ReadingView() }
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
}
