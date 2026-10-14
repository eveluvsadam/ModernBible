# ModernBible

A complete, ready-to-open Xcode project (bundle id `elpeepee.ModernBible`, iOS 18.4 target) for a premium, ad-free Bible app in English / French / Haitian Creole.

## Opening it

Double-click `ModernBible.xcodeproj` in this folder. It's a real Xcode project — MVVM architecture, Core Data model, bundled sample Bible text, all 3 languages localized, all major screens built. Pick a simulator and hit ⌘R.

## What's real vs. what's a placeholder

Built and working out of the box:
- Full MVVM source tree: onboarding, reading, search, bookmarks, highlights, notes, history, prayer journal, reading plans, study/commentary, settings — all wired to real services, not mockups.
- A real Core Data model (`Persistence/ModernBible.xcdatamodeld`) backing bookmarks, highlights, notes, recents, prayer entries, and reading plan progress — `UserDataService` reads/writes it directly.
- A real Bible text service (`Services/BibleDataService.swift`) reading bundled JSON (`Resources/BibleData/*.json`) with working chapter lookup and case-insensitive search.
- Full `en` / `fr` / `ht` localization with an in-app language switcher (Settings) independent of the device's system language.
- Light/dark/system theme, adjustable font size, reading background presets, local daily-verse notifications, verse sharing via the system share sheet.

Explicitly placeholder / needs your input before shipping:
- **English (KJV) now includes the complete text of Genesis 1–4** (106 verses, sourced directly from Project Gutenberg's public-domain KJV text) plus Psalm 23 and John 3:16–18 — enough to actually read a few full chapters in the app, not just isolated verses. Everything past Genesis 4 is still missing.
- **French (Louis Segond 1910) and Haitian Creole remain small samples** — a handful of well-known verses (Genesis 1:1–5, John 3:16–17) for French; the Haitian Creole file has `[PLACEHOLDER]` verse text because I don't have a verified, licensed source for exact Haitian Creole wording — I didn't want to risk misquoting scripture. See `docs/DATA_SOURCES.md` for licensing-safe sources to pull complete text from for all three languages.
- **App icon** is a plain placeholder graphic (`Assets.xcassets/AppIcon.appiconset`) — swap before submission.
- **Audio Bible, commentary, and cross-references** are wired up in the UI/services but have no data source connected yet (`AudioService`, `StudyView`) — see `docs/DATA_SOURCES.md` for provider options.
- **Firebase cloud sync** (`Services/FirebaseSyncService.swift`) is stubbed with commented-out calls — add the Firebase SPM package if/when you want optional cross-device sync.

## Growing the Bible text dataset

`BibleDataService` reads from JSON rather than SQLite specifically so this project builds and runs with zero extra setup — no SPM package, no manually linking `libsqlite3`. It'll comfortably handle a full single translation (~31,000 verses) in memory. If you later want indexed full-text search across multiple large translations at once, the `docs/DATABASE_STRUCTURE.md` SQLite/FTS5 schema is ready to switch to — swap the implementation behind `BibleDataProviding` and no other code needs to change.

## Also in this folder

- `docs/ARCHITECTURE.md` — app architecture, tech stack, MVVM layout
- `docs/DATABASE_STRUCTURE.md` — Core Data schema + the SQLite schema to grow into later
- `docs/DATA_SOURCES.md` — where to get full, properly licensed Bible/audio/commentary text for all 3 languages
- `docs/ROADMAP.md` — phased MVP → v1.0 → post-launch plan
