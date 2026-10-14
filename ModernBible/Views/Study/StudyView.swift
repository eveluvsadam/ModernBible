import SwiftUI

/// Commentary + cross-references for the current reading position (see `commentary` and
/// `cross_references` tables in docs/DATABASE_STRUCTURE.md).
struct StudyView: View {
    @EnvironmentObject private var appState: AppState
    @State private var commentaryText: String = ""
    @State private var crossReferences: [VerseReference] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox(L("study.commentary")) {
                    Text(commentaryText.isEmpty ? L("study.commentary.empty") : commentaryText)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox(L("study.cross_references")) {
                    if crossReferences.isEmpty {
                        Text(L("study.cross_references.empty"))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(crossReferences, id: \.self) { ref in
                            Button(ref.displayString) {
                                appState.navigate(to: ref.bookId, chapter: ref.chapter, verse: ref.verse)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.tint)
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(L("more.study"))
    }
}

#Preview {
    NavigationStack { StudyView() }
        .environmentObject(AppState())
}
