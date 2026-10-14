import SwiftUI

/// The core reusable unit of the whole app: one verse, with its number, highlight,
/// bookmark state, and a context menu for the actions that apply per-verse.
struct VerseRow: View {
    let verse: Verse
    let fontSize: Double
    let highlightColor: HighlightColor?
    let isBookmarked: Bool
    let onBookmark: () -> Void
    let onHighlight: (HighlightColor?) -> Void
    let onNote: () -> Void
    let onShare: () -> Void

    @ScaledMetric(relativeTo: .body) private var dynamicScale: CGFloat = 1

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(verse.verse)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 22, alignment: .trailing)
                .padding(.top, 3)

            Text(verse.text)
                .font(.system(size: fontSize * dynamicScale))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    highlightColor.map { Color(hex: $0.hex) } ?? .clear,
                    in: RoundedRectangle(cornerRadius: 4)
                )

            if isBookmarked {
                Image(systemName: "bookmark.fill")
                    .font(.caption)
                    .foregroundStyle(.tint)
                    .padding(.top, 4)
            }
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button(isBookmarked ? L("verse.remove_bookmark") : L("verse.bookmark"), systemImage: "bookmark") { onBookmark() }
            Menu(L("verse.highlight"), systemImage: "highlighter") {
                ForEach(HighlightColor.allCases) { color in
                    Button {
                        onHighlight(color)
                    } label: {
                        Label(color.rawValue.capitalized, systemImage: "circle.fill")
                    }
                }
                if highlightColor != nil {
                    Button(L("verse.remove_highlight"), systemImage: "xmark.circle") { onHighlight(nil) }
                }
            }
            Button(L("verse.add_note"), systemImage: "note.text") { onNote() }
            Button(L("verse.share"), systemImage: "square.and.arrow.up") { onShare() }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(L("verse.accessibility_prefix")) \(verse.verse). \(verse.text)")
    }
}

#Preview {
    VerseRow(
        verse: Verse(bookId: 43, chapter: 3, verse: 16, text: "For God so loved the world, that he gave his only begotten Son..."),
        fontSize: 17,
        highlightColor: .yellow,
        isBookmarked: true,
        onBookmark: {}, onHighlight: { _ in }, onNote: {}, onShare: {}
    )
    .padding()
}
