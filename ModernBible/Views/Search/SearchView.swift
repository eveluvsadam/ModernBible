import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        List(viewModel.results) { result in
            NavigationLink {
                ReadingView() // navigates via appState below
                    .onAppear {
                        appState.currentBookId = result.verse.bookId
                        appState.currentChapter = result.verse.chapter
                    }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(result.bookName) \(result.verse.chapter):\(result.verse.verse)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.tint)
                    Text(result.verse.text)
                        .font(.body)
                        .lineLimit(3)
                }
                .padding(.vertical, 2)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.results.isEmpty && !viewModel.query.isEmpty {
                ContentUnavailableView.search(text: viewModel.query)
            }
        }
        .searchable(text: $viewModel.query, prompt: L("search.prompt"))
        .onChange(of: viewModel.query) { _, newValue in
            viewModel.onQueryChanged(newValue, translation: appState.currentTranslation)
        }
        .navigationTitle(L("tab.search"))
    }
}

#Preview {
    NavigationStack { SearchView() }
        .environmentObject(AppState())
}
