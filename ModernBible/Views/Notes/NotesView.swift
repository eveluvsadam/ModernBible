import SwiftUI

struct NotesView: View {
    @State private var notes: [Note] = []

    var body: some View {
        List(notes) { note in
            VStack(alignment: .leading, spacing: 4) {
                Text(note.reference.displayString)
                    .font(.subheadline.bold())
                    .foregroundStyle(.tint)
                Text(note.body)
                    .font(.body)
                    .lineLimit(3)
                Text(note.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
        .overlay {
            if notes.isEmpty {
                ContentUnavailableView(L("notes.empty.title"), systemImage: "note.text", description: Text(L("notes.empty.subtitle")))
            }
        }
        .navigationTitle(L("more.notes"))
        .onAppear { notes = UserDataService.shared.allNotes() }
    }
}

struct BookmarksView: View {
    @State private var bookmarks: [Bookmark] = []

    var body: some View {
        List(bookmarks) { bookmark in
            HStack {
                Image(systemName: "bookmark.fill").foregroundStyle(.tint)
                Text(bookmark.reference.displayString)
                Spacer()
                Text(bookmark.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .overlay {
            if bookmarks.isEmpty {
                ContentUnavailableView(L("bookmarks.empty.title"), systemImage: "bookmark", description: Text(L("bookmarks.empty.subtitle")))
            }
        }
        .navigationTitle(L("more.bookmarks"))
        .onAppear { bookmarks = UserDataService.shared.allBookmarks() }
    }
}

struct HistoryView: View {
    @State private var recents: [RecentVerse] = []

    var body: some View {
        List(recents) { recent in
            HStack {
                Text(recent.reference.displayString)
                Spacer()
                Text(recent.viewedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .overlay {
            if recents.isEmpty {
                ContentUnavailableView(L("history.empty.title"), systemImage: "clock.arrow.circlepath", description: Text(L("history.empty.subtitle")))
            }
        }
        .navigationTitle(L("more.history"))
        .onAppear { recents = UserDataService.shared.recentVerses(limit: 100) }
    }
}

#Preview { NavigationStack { NotesView() } }
