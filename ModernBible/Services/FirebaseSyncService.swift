import Foundation

// Uncomment once the Firebase SPM package is added (FirebaseAuth, FirebaseFirestore):
// import FirebaseCore
// import FirebaseAuth
// import FirebaseFirestore

/// Fully optional. The app works 100% offline without this ever being called.
/// Users opt in via Settings → iCloud/Cloud Sync toggle.
final class FirebaseSyncService {
    static let shared = FirebaseSyncService()

    private(set) var isEnabled = false

    func configureIfNeeded() {
        // FirebaseApp.configure()
    }

    func signInAnonymouslyIfNeeded(completion: @escaping (Result<String, Error>) -> Void) {
        // Auth.auth().signInAnonymously { result, error in ... }
    }

    func syncBookmarks(_ bookmarks: [Bookmark]) {
        // Firestore.firestore().collection("users/\(uid)/bookmarks") upsert, keyed by bookmark.id
    }

    func syncHighlights(_ highlights: [Highlight]) { }
    func syncNotes(_ notes: [Note]) { }
    func syncPrayerEntries(_ entries: [PrayerEntry]) { }
    func syncSettings(_ settings: UserSettings) { }

    /// Pulls remote changes newer than the last local sync timestamp and merges last-write-wins.
    func pullRemoteChanges(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}
