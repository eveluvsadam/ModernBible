# Architecture

## Tech stack

| Layer | Choice | Why |
|---|---|---|
| UI | SwiftUI (iOS 17+ target) | Modern, declarative, fastest to build a polished UI with |
| Architecture | MVVM | Clean separation, testable, matches SwiftUI's data-flow model |
| Local storage | Core Data (+ SQLite for Bible text) | Core Data for user data (bookmarks/notes/highlights/plans), a flat SQLite DB for the Bible text itself (fast full-text search, small footprint) |
| Cloud sync (optional) | Firebase (Auth + Firestore) | User opts in; free tier is generous; simplest path to cross-device sync |
| Notifications | UserNotifications framework | Daily verse reminders, reading plan reminders |
| Audio | AVFoundation + AVPlayer | Streaming/downloaded audio Bible playback |
| Localization | Native `.strings` + `String Catalog` (iOS 17) | en / fr / ht |
| Dependency management | Swift Package Manager only | No CocoaPods — lighter, faster builds |

## High-level module map

```
BibleApp (App target)
├── App/                  – App entry point, root TabView, app-wide environment
├── Models/               – Plain Swift structs/enums (Bible domain + user data)
├── ViewModels/           – ObservableObject / @Observable classes, one per screen/feature
├── Views/                – SwiftUI views, grouped by feature
│   ├── Onboarding/
│   ├── Home/
│   ├── Reading/
│   ├── Search/
│   ├── Bookmarks/
│   ├── Notes/
│   ├── Highlights/
│   ├── Study/
│   ├── Prayer/
│   ├── Settings/
│   └── Components/       – Reusable, dumb UI pieces (buttons, verse rows, pickers)
├── Services/             – Business logic + I/O: BibleDataService, PersistenceController,
│                           NotificationService, AudioService, FirebaseSyncService, SearchIndexService
├── Persistence/           – Core Data stack, .xcdatamodeld
├── Localization/          – Localizable.strings per language, LocalizationManager
├── Resources/             – Bundled Bible JSON/SQLite, fonts, themes, images
└── Utilities/             – Extensions, Constants, Haptics, Theme tokens
```

## MVVM pattern used throughout

- **View**: pure SwiftUI, no business logic beyond simple formatting. Binds to a `@StateObject` / `@ObservedObject` (or `@Environment` for app-wide singletons like `ThemeManager`, `LocalizationManager`).
- **ViewModel**: `final class XViewModel: ObservableObject` exposing `@Published` state and intent methods (`func loadChapter()`, `func toggleBookmark()`). Never imports SwiftUI's `View` protocol — keeps it testable.
- **Model**: Codable structs for Bible content (`Book`, `Chapter`, `Verse`), Core Data `NSManagedObject` subclasses for user-generated data (`BookmarkEntity`, `HighlightEntity`, `NoteEntity`, `ReadingPlanProgressEntity`, `PrayerEntryEntity`, `RecentVerseEntity`).
- **Service**: Singletons/injected dependencies that talk to disk, network, or system frameworks. ViewModels depend on service *protocols* (e.g. `BibleDataProviding`), not concrete types, so they're mockable in tests.

## Navigation

Root is a `TabView` (5 tabs): **Read**, **Search**, **Plans**, **Prayer**, **More** (Settings/Study/Bookmarks live under More or as a 4th/5th tab depending on final IA). Each tab root uses `NavigationStack` (iOS 16+) for push navigation (Book → Chapter → Verse detail / cross-references).

State that must survive tab switches (last read position, current theme, current translation) lives in app-level `@EnvironmentObject`s injected at the `WindowGroup` root:

- `AppState` (current translation, current book/chapter/verse, last-read position)
- `ThemeManager` (color scheme, accent, reading background, font size)
- `LocalizationManager` (current language override, independent of system language)

## Performance & lightweight principles

- Bible text ships as pre-parsed SQLite (not JSON parsed at runtime) — instant chapter loads, no big JSON decode on launch.
- Verse rows use `LazyVStack`/`List` with stable `id`s — no re-render storms scrolling a whole chapter.
- Images/icons are SF Symbols wherever possible (zero asset weight, automatic Dark Mode + Dynamic Type support).
- Search uses a pre-built inverted index (SQLite FTS5) — sub-50ms verse search even across a full translation.
- Audio Bible streams by default and caches only what's played, with an explicit "download for offline" action per book/chapter to avoid bloating app storage silently.

## Accessibility

- All interactive elements have `accessibilityLabel`/`accessibilityHint`.
- Font sizing respects Dynamic Type (`@ScaledMetric`) in addition to the app's own in-app font-size slider (the slider sets a *baseline* size that Dynamic Type then scales further).
- Color contrast checked for all themes (including custom backgrounds) — verse text always renders on a scrim layer so custom background images never break readability.
- VoiceOver reads verse number + text as one coherent phrase ("Verse 16. For God so loved the world...").

## Ad-free / monetization stance

No ad SDKs, no interstitials, no paywall dark patterns. If monetization is ever added later (e.g. optional one-time "supporter" tip or premium themes pack), it should be additive and never gate core reading/search/notes functionality.
