import CoreData
import Combine

protocol RecentsProviding {
    func recordView(translationId: String, bookId: Int, chapter: Int, verse: Int)
    func recentVerses(limit: Int) -> [RecentVerse]
}

/// One service fronting all Core Data user-data CRUD (bookmarks, highlights, notes, recents,
/// prayer entries, reading plan progress). ViewModels depend on this rather than touching
/// NSManagedObjectContext directly, so views/view models stay Core-Data-agnostic and testable.
///
/// The entity classes referenced here (BookmarkEntity, HighlightEntity, etc.) are generated
/// automatically by Xcode from Persistence/ModernBible.xcdatamodeld (codeGenerationType="class") —
/// there are no separate +CoreDataClass files to maintain.
final class UserDataService: ObservableObject, RecentsProviding {
    static let shared = UserDataService()

    private let context: NSManagedObjectContext
    private let maxRecentHistory = 100

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    private func save() {
        guard context.hasChanges else { return }
        do { try context.save() } catch { assertionFailure("Core Data save failed: \(error)") }
    }

    private func referencePredicate(translationId: String, reference: VerseReference) -> NSPredicate {
        NSPredicate(
            format: "translationId == %@ AND bookId == %d AND chapter == %d AND verse == %d",
            translationId, reference.bookId, reference.chapter, reference.verse
        )
    }

    // MARK: Bookmarks

    func toggleBookmark(translationId: String, reference: VerseReference) {
        let request = BookmarkEntity.fetchRequest()
        request.predicate = referencePredicate(translationId: translationId, reference: reference)
        if let existing = try? context.fetch(request).first {
            context.delete(existing)
        } else {
            let bookmark = BookmarkEntity(context: context)
            bookmark.id = UUID()
            bookmark.translationId = translationId
            bookmark.bookId = Int16(reference.bookId)
            bookmark.chapter = Int16(reference.chapter)
            bookmark.verse = Int16(reference.verse)
            bookmark.createdAt = Date()
        }
        save()
    }

    func isBookmarked(translationId: String, reference: VerseReference) -> Bool {
        let request = BookmarkEntity.fetchRequest()
        request.predicate = referencePredicate(translationId: translationId, reference: reference)
        request.fetchLimit = 1
        return (try? context.count(for: request)) ?? 0 > 0
    }

    func allBookmarks() -> [Bookmark] {
        let request = BookmarkEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let entities = (try? context.fetch(request)) ?? []
        return entities.compactMap { entity in
            guard let id = entity.id, let translationId = entity.translationId, let createdAt = entity.createdAt else { return nil }
            return Bookmark(
                id: id,
                translationId: translationId,
                reference: VerseReference(bookId: Int(entity.bookId), chapter: Int(entity.chapter), verse: Int(entity.verse)),
                createdAt: createdAt
            )
        }
    }

    // MARK: Highlights

    func setHighlight(_ color: HighlightColor?, translationId: String, reference: VerseReference) {
        let request = HighlightEntity.fetchRequest()
        request.predicate = referencePredicate(translationId: translationId, reference: reference)
        let existing = try? context.fetch(request).first

        guard let color else {
            if let existing { context.delete(existing) }
            save()
            return
        }

        let highlight = existing ?? HighlightEntity(context: context)
        if existing == nil {
            highlight.id = UUID()
            highlight.translationId = translationId
            highlight.bookId = Int16(reference.bookId)
            highlight.chapter = Int16(reference.chapter)
            highlight.verse = Int16(reference.verse)
            highlight.createdAt = Date()
        }
        highlight.colorHex = color.hex
        save()
    }

    func highlight(translationId: String, reference: VerseReference) -> HighlightColor? {
        let request = HighlightEntity.fetchRequest()
        request.predicate = referencePredicate(translationId: translationId, reference: reference)
        request.fetchLimit = 1
        guard let entity = try? context.fetch(request).first, let hex = entity.colorHex else { return nil }
        return HighlightColor.allCases.first { $0.hex == hex }
    }

    // MARK: Notes

    func saveNote(_ body: String, translationId: String, reference: VerseReference) {
        let request = NoteEntity.fetchRequest()
        request.predicate = referencePredicate(translationId: translationId, reference: reference)
        let now = Date()

        if let existing = try? context.fetch(request).first {
            if body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                context.delete(existing)
            } else {
                existing.body = body
                existing.updatedAt = now
            }
        } else if !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let note = NoteEntity(context: context)
            note.id = UUID()
            note.translationId = translationId
            note.bookId = Int16(reference.bookId)
            note.chapter = Int16(reference.chapter)
            note.verse = Int16(reference.verse)
            note.body = body
            note.createdAt = now
            note.updatedAt = now
        }
        save()
    }

    func note(translationId: String, reference: VerseReference) -> Note? {
        let request = NoteEntity.fetchRequest()
        request.predicate = referencePredicate(translationId: translationId, reference: reference)
        request.fetchLimit = 1
        guard let entity = try? context.fetch(request).first else { return nil }
        return note(from: entity)
    }

    func allNotes() -> [Note] {
        let request = NoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        let entities = (try? context.fetch(request)) ?? []
        return entities.compactMap(note(from:))
    }

    private func note(from entity: NoteEntity) -> Note? {
        guard
            let id = entity.id,
            let translationId = entity.translationId,
            let body = entity.body,
            let createdAt = entity.createdAt,
            let updatedAt = entity.updatedAt
        else { return nil }
        return Note(
            id: id,
            translationId: translationId,
            reference: VerseReference(bookId: Int(entity.bookId), chapter: Int(entity.chapter), verse: Int(entity.verse)),
            body: body,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: Recents

    func recordView(translationId: String, bookId: Int, chapter: Int, verse: Int) {
        let entity = RecentVerseEntity(context: context)
        entity.id = UUID()
        entity.translationId = translationId
        entity.bookId = Int16(bookId)
        entity.chapter = Int16(chapter)
        entity.verse = Int16(verse)
        entity.viewedAt = Date()
        save()
        pruneRecentsIfNeeded()
    }

    private func pruneRecentsIfNeeded() {
        let request = RecentVerseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "viewedAt", ascending: false)]
        guard let all = try? context.fetch(request), all.count > maxRecentHistory else { return }
        for entity in all[maxRecentHistory...] {
            context.delete(entity)
        }
        save()
    }

    func recentVerses(limit: Int = 50) -> [RecentVerse] {
        let request = RecentVerseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "viewedAt", ascending: false)]
        request.fetchLimit = limit
        let entities = (try? context.fetch(request)) ?? []
        return entities.compactMap { entity in
            guard let id = entity.id, let translationId = entity.translationId, let viewedAt = entity.viewedAt else { return nil }
            return RecentVerse(
                id: id,
                translationId: translationId,
                reference: VerseReference(bookId: Int(entity.bookId), chapter: Int(entity.chapter), verse: Int(entity.verse)),
                viewedAt: viewedAt
            )
        }
    }

    // MARK: Prayer Journal

    func savePrayerEntry(_ entry: PrayerEntry) {
        let request = PrayerEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
        let managed = (try? context.fetch(request).first) ?? PrayerEntryEntity(context: context)
        managed.id = entry.id
        managed.title = entry.title
        managed.body = entry.body
        managed.category = entry.category.rawValue
        managed.isAnswered = entry.isAnswered
        managed.createdAt = entry.createdAt
        managed.answeredAt = entry.answeredAt
        save()
    }

    func markAnswered(_ entryId: UUID) {
        let request = PrayerEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entryId as CVarArg)
        guard let entity = try? context.fetch(request).first else { return }
        entity.isAnswered = true
        entity.answeredAt = Date()
        save()
    }

    func allPrayerEntries() -> [PrayerEntry] {
        let request = PrayerEntryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let entities = (try? context.fetch(request)) ?? []
        return entities.compactMap { entity in
            guard
                let id = entity.id,
                let title = entity.title,
                let body = entity.body,
                let categoryRaw = entity.category,
                let category = PrayerCategory(rawValue: categoryRaw),
                let createdAt = entity.createdAt
            else { return nil }
            return PrayerEntry(id: id, title: title, body: body, category: category, isAnswered: entity.isAnswered, createdAt: createdAt, answeredAt: entity.answeredAt)
        }
    }

    // MARK: Reading Plans

    func startPlan(_ plan: ReadingPlanDefinition) {
        let request = ReadingPlanEntity.fetchRequest()
        request.predicate = NSPredicate(format: "planKey == %@", plan.id)
        guard (try? context.fetch(request).first) == nil else { return } // already started

        let entity = ReadingPlanEntity(context: context)
        entity.id = UUID()
        entity.title = plan.title
        entity.planKey = plan.id
        entity.totalDays = Int16(plan.totalDays)
        entity.startedAt = Date()
        save()
    }

    func markDayComplete(planId: UUID, dayIndex: Int) {
        let request = ReadingPlanEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", planId as CVarArg)
        guard let plan = try? context.fetch(request).first else { return }

        let progress = ReadingPlanDayProgressEntity(context: context)
        progress.id = UUID()
        progress.dayIndex = Int16(dayIndex)
        progress.completedAt = Date()
        progress.plan = plan
        save()
    }

    func activePlans() -> [ReadingPlanProgress] {
        let request = ReadingPlanEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: false)]
        let entities = (try? context.fetch(request)) ?? []
        return entities.compactMap { entity in
            guard let id = entity.id, let title = entity.title, let startedAt = entity.startedAt, let planKey = entity.planKey else { return nil }
            let completedDays = (entity.dayProgress as? Set<ReadingPlanDayProgressEntity> ?? [])
                .map { Int($0.dayIndex) }
            return ReadingPlanProgress(
                id: id,
                planKey: planKey,
                title: title,
                totalDays: Int(entity.totalDays),
                startedAt: startedAt,
                completedDayIndexes: Set(completedDays)
            )
        }
    }
}

final class RecentsService {
    static let shared: RecentsProviding = UserDataService.shared
}
