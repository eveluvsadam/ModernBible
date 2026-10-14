# Development Roadmap

## Phase 0 — Setup (few days)
- Create Xcode project, SPM dependencies (GRDB.swift for SQLite, Firebase SDK).
- Secure Bible text source(s) and licensing for at least one translation per language.
- Set up Core Data model, base app shell (TabView + NavigationStack), localization scaffolding.

## Phase 1 — MVP (2–4 weeks)
Goal: something you'd actually want to read from daily.
- Bible reading: book/chapter navigation, verse-by-verse display, one bundled translation per language.
- Language switch (en/fr/ht) fully localizes UI (not Bible content translation logic yet — just app chrome).
- Dark/light mode, font size slider.
- Bookmarks (add/remove/list).
- Basic verse search (SQLite FTS5).
- Onboarding flow (3–4 screens: welcome, choose language, choose translation, notification opt-in).

## Phase 2 — Core feature-complete (3–5 weeks)
- Multiple translations, in-app translation switcher.
- Highlights with color picker.
- Personal notes attached to verses.
- Daily verse push notification (local notification, not server-push — simpler, works offline).
- Reading plans + progress tracking (start with 2–3 bundled plans: e.g. "New Testament in 90 days", "Proverbs in a month", "Chronological in a year").
- Recently viewed verse history.
- Verse sharing (share sheet: image card generation + plain text to Messages/Mail/social).

## Phase 3 — Premium polish (2–4 weeks)
- Custom themes + reading backgrounds.
- Prayer journal section (entries, categories, mark-as-answered).
- Study section: commentary + cross-references for the current passage.
- Audio Bible (streaming + per-chapter download).
- Smooth transitions/animations pass (page turns, tab transitions, verse highlight animation).
- Full accessibility pass (VoiceOver labels, Dynamic Type stress-test, contrast check on all themes).

## Phase 4 — Cloud sync (optional, 1–2 weeks)
- Firebase Auth (anonymous + optional email/Apple Sign-In).
- Firestore sync for bookmarks/highlights/notes/prayer entries/settings.
- Conflict resolution (last-write-wins), sync status indicator in Settings.

## Phase 5 — App Store readiness (1–2 weeks)
- App icon, launch screen, screenshots (all 3 languages), App Store description (localized).
- Privacy nutrition label (what data is collected — likely minimal/none unless cloud sync is used).
- TestFlight beta with a small group across all 3 languages, gather feedback.
- Performance pass: launch time, memory footprint, Instruments profiling on an older supported device.
- Final licensing check on all bundled Bible text/audio/commentary content.
- Submit for review.

## Post-launch backlog (ideas, not committed)
- Additional translations via API.Bible.
- Widget (Today's verse on Home Screen / Lock Screen).
- Apple Watch companion (daily verse, quick prayer log).
- Reading streaks / gentle habit-building (never guilt-driven, no dark patterns).
- Community reading plans / group challenges (would require backend beyond Firebase basics).
