import SwiftUI

struct PrayerJournalView: View {
    @State private var entries: [PrayerEntry] = []
    @State private var showingNewEntry = false

    var body: some View {
        List {
            ForEach(PrayerCategory.allCases) { category in
                let categoryEntries = entries.filter { $0.category == category }
                if !categoryEntries.isEmpty {
                    Section(category.rawValue.capitalized) {
                        ForEach(categoryEntries) { entry in
                            PrayerEntryRow(entry: entry)
                        }
                    }
                }
            }
        }
        .overlay {
            if entries.isEmpty {
                ContentUnavailableView(L("prayer.empty.title"), systemImage: "hands.sparkles", description: Text(L("prayer.empty.subtitle")))
            }
        }
        .navigationTitle(L("tab.prayer"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingNewEntry = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel(L("prayer.new"))
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            NewPrayerEntryView { entries = UserDataService.shared.allPrayerEntries() }
        }
        .onAppear { entries = UserDataService.shared.allPrayerEntries() }
    }
}

private struct PrayerEntryRow: View {
    let entry: PrayerEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.title).font(.headline)
                Spacer()
                if entry.isAnswered {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                }
            }
            Text(entry.body).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
        }
        .padding(.vertical, 2)
    }
}

struct NewPrayerEntryView: View {
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var body_ = ""
    @State private var category: PrayerCategory = .requests

    var body: some View {
        NavigationStack {
            Form {
                TextField(L("prayer.field.title"), text: $title)
                Picker(L("prayer.field.category"), selection: $category) {
                    ForEach(PrayerCategory.allCases) { Text($0.rawValue.capitalized).tag($0) }
                }
                TextField(L("prayer.field.body"), text: $body_, axis: .vertical)
                    .lineLimit(5...10)
            }
            .navigationTitle(L("prayer.new"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(L("common.cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("common.save")) {
                        let entry = PrayerEntry(id: UUID(), title: title, body: body_, category: category, isAnswered: false, createdAt: Date(), answeredAt: nil)
                        UserDataService.shared.savePrayerEntry(entry)
                        onSave()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview { NavigationStack { PrayerJournalView() } }
