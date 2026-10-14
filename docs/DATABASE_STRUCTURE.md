# Database Structure

Two separate stores, on purpose: Bible text is read-heavy, static, and shipped with the app; user data is small, mutable, and personal. Mixing them into one Core Data store makes the initial DB huge and slows first-launch migration.

## 1. Bible text store — SQLite (bundled, read-only)

One `.sqlite` file per translation, e.g. `kjv.sqlite`, `niv.sqlite`, `lsg.sqlite` (Louis Segond, French), `htcv.sqlite` (Haitian Creole). Bundle only 1–2 free/public-domain translations in-app; others downloadable on demand (see DATA_SOURCES.md).

```sql
CREATE TABLE books (
  id INTEGER PRIMARY KEY,       -- 1–66
  name TEXT NOT NULL,           -- localized display name, or a key resolved via Localizable.strings
  abbreviation TEXT NOT NULL,
  testament TEXT NOT NULL,      -- 'OT' | 'NT'
  chapter_count INTEGER NOT NULL,
  sort_order INTEGER NOT NULL
);

CREATE TABLE verses (
  id INTEGER PRIMARY KEY,
  book_id INTEGER NOT NULL REFERENCES books(id),
  chapter INTEGER NOT NULL,
  verse INTEGER NOT NULL,
  text TEXT NOT NULL,
  UNIQUE(book_id, chapter, verse)
);

-- Full text search index (SQLite FTS5) for fast verse search
CREATE VIRTUAL TABLE verses_fts USING fts5(
  text,
  content='verses',
  content_rowid='id'
);

CREATE TABLE commentary (          -- optional, for the Study section
  id INTEGER PRIMARY KEY,
  book_id INTEGER NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER,                  -- NULL = applies to whole chapter
  source TEXT NOT NULL,            -- e.g. "Matthew Henry (public domain)"
  body TEXT NOT NULL
);

CREATE TABLE cross_references (
  id INTEGER PRIMARY KEY,
  from_book_id INTEGER NOT NULL,
  from_chapter INTEGER NOT NULL,
  from_verse INTEGER NOT NULL,
  to_book_id INTEGER NOT NULL,
  to_chapter INTEGER NOT NULL,
  to_verse INTEGER NOT NULL
);
```

Indexes: `CREATE INDEX idx_verses_lookup ON verses(book_id, chapter, verse);`

Access pattern: `BibleDataService` opens each translation's file lazily (only when selected) via a lightweight SQLite wrapper (GRDB.swift recommended, or raw `sqlite3` C API to avoid a dependency).

## 2. User data store — Core Data (`BibleApp.xcdatamodeld`)

Create these entities in Xcode's Core Data model editor:

### `BookmarkEntity`
| Attribute | Type |
|---|---|
| id | UUID |
| translationId | String |
| bookId | Int16 |
| chapter | Int16 |
| verse | Int16 |
| createdAt | Date |

### `HighlightEntity`
| Attribute | Type |
|---|---|
| id | UUID |
| translationId | String |
| bookId | Int16 |
| chapter | Int16 |
| verse | Int16 |
| colorHex | String |   *(e.g. "#FFE08A" — yellow, green, blue, pink, purple presets)*
| createdAt | Date |

### `NoteEntity`
| Attribute | Type |
|---|---|
| id | UUID |
| translationId | String |
| bookId | Int16 |
| chapter | Int16 |
| verse | Int16 |
| body | String |
| createdAt | Date |
| updatedAt | Date |

### `ReadingPlanEntity`
| Attribute | Type |
|---|---|
| id | UUID |
| title | String |
| totalDays | Int16 |
| startedAt | Date |
| planKey | String |  *(references a bundled JSON plan definition, e.g. "365-chronological")*

### `ReadingPlanDayProgressEntity`
| Attribute | Type |
|---|---|
| id | UUID |
| planId | UUID |
| dayIndex | Int16 |
| completedAt | Date? |

Relationship: `ReadingPlanEntity` →→ `ReadingPlanDayProgressEntity` (one-to-many, cascade delete).

### `PrayerEntryEntity`
| Attribute | Type |
|---|---|
| id | UUID |
| title | String |
| body | String |
| category | String |  *(e.g. "Family", "Health", "Gratitude", "Requests")*
| isAnswered | Bool |
| createdAt | Date |
| answeredAt | Date? |

### `RecentVerseEntity`
| Attribute | Type |
|---|---|
| id | UUID |
| translationId | String |
| bookId | Int16 |
| chapter | Int16 |
| verse | Int16 |
| viewedAt | Date |

Keep only the most recent ~100 rows (prune on write) so history stays lightweight.

### `UserSettingsEntity` (singleton row)
| Attribute | Type |
|---|---|
| preferredLanguage | String |     *(en / fr / ht)*
| preferredTranslationId | String |
| fontSize | Float |
| theme | String |                 *(system / light / dark)*
| readingBackground | String |     *(key into bundled background assets)*
| dailyVerseNotificationEnabled | Bool |
| dailyVerseNotificationTime | Date |
| cloudSyncEnabled | Bool |

## 3. Optional cloud sync (Firebase Firestore)

Mirrors the Core Data entities above as documents under `users/{uid}/bookmarks`, `.../highlights`, `.../notes`, `.../prayerEntries`, `.../settings`. Sync strategy: last-write-wins with `updatedAt` timestamp comparison, triggered on app foreground + on local save, debounced. This is strictly opt-in (toggle in Settings) — the app is fully functional offline-only with no account.
