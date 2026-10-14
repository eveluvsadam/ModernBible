import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ReadingView()
            }
            .tabItem { Label(L("tab.read"), systemImage: "book") }

            NavigationStack {
                SearchView()
            }
            .tabItem { Label(L("tab.search"), systemImage: "magnifyingglass") }

            NavigationStack {
                ReadingPlansView()
            }
            .tabItem { Label(L("tab.plans"), systemImage: "calendar") }

            NavigationStack {
                PrayerJournalView()
            }
            .tabItem { Label(L("tab.prayer"), systemImage: "hands.sparkles") }

            NavigationStack {
                MoreView()
            }
            .tabItem { Label(L("tab.more"), systemImage: "ellipsis.circle") }
        }
    }
}

/// Groups Bookmarks, Highlights, Notes, History, Study, and Settings behind one tab
/// to keep the tab bar to 5 items (Apple HIG recommendation).
struct MoreView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(destination: BookmarksView()) {
                    Label(L("more.bookmarks"), systemImage: "bookmark")
                }
                NavigationLink(destination: NotesView()) {
                    Label(L("more.notes"), systemImage: "note.text")
                }
                NavigationLink(destination: HistoryView()) {
                    Label(L("more.history"), systemImage: "clock.arrow.circlepath")
                }
                NavigationLink(destination: StudyView()) {
                    Label(L("more.study"), systemImage: "text.book.closed")
                }
            }
            Section {
                NavigationLink(destination: SettingsView()) {
                    Label(L("more.settings"), systemImage: "gearshape")
                }
            }
        }
        .navigationTitle(L("tab.more"))
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager.shared)
}
