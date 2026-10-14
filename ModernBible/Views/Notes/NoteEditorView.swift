import SwiftUI

struct NoteEditorView: View {
    let verse: Verse
    let translation: Translation

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(verse.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                TextEditor(text: $text)
                    .padding(8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .frame(minHeight: 200)

                Spacer()
            }
            .padding(.top)
            .navigationTitle(L("note.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("common.save")) {
                        UserDataService.shared.saveNote(text, translationId: translation.id, reference: verse.reference)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                text = UserDataService.shared.note(translationId: translation.id, reference: verse.reference)?.body ?? ""
            }
        }
    }
}

#Preview {
    NoteEditorView(verse: Verse(bookId: 43, chapter: 3, verse: 16, text: "For God so loved the world..."), translation: .kjv)
}
