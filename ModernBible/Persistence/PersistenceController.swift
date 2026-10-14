import CoreData

/// Core Data stack for USER data only (bookmarks, highlights, notes, plans, prayer, history, settings).
/// Bible text itself lives in a separate bundled SQLite store — see Services/BibleDataService.swift.
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Model name must match the .xcdatamodeld you create per docs/DATABASE_STRUCTURE.md
        container = NSPersistentContainer(name: "ModernBible")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                // In production, surface this via a non-fatal alert rather than crashing —
                // but a corrupted Core Data store on a *user data* store is rare and recoverable
                // by falling back to a fresh store.
                assertionFailure("Core Data failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func saveContext() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save context: \(error)")
        }
    }
}
