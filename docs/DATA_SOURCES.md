# Bible Data Sources & Offline Storage

> **Current build note:** the shipped `BibleDataService` reads from bundled JSON files in
> `Resources/BibleData/` rather than SQLite, to avoid requiring an SPM dependency or manually
> linking `libsqlite3` — see that file's header comment for why, and how to swap to
> GRDB.swift + SQLite FTS5 later if you need full-text search across a complete translation
> at scale. The bundled JSON currently contains only a handful of well-known sample verses
> (Genesis 1, Psalm 23, John 3) for English (KJV) and French (Louis Segond 1910) — enough to
> make the app functional and demoable. The Haitian Creole file ships with `[PLACEHOLDER]`
> verse text: I don't have a verified, licensed source for exact Haitian Creole Bible wording
> memorized, and didn't want to risk misquoting scripture in a language I can't confidently
> check. Replace it with real text from a licensed source below before shipping anything
> user-facing.

## Text — public-domain / freely licensable translations

| Language | Translation | License status | Notes |
|---|---|---|---|
| English | KJV (King James Version) | Public domain | Safe to bundle fully offline |
| English | WEB (World English Bible) | Public domain | Modern-English public-domain alternative |
| English | ASV (American Standard Version) | Public domain | |
| English | NIV, ESV, NLT | **Copyrighted** | Require a license from Biblica/Crossway/Tyndale, or use via the **API.Bible** or **YouVersion** API under their terms — do not bundle raw text without a license |
| French | Louis Segond 1910 (LSG) | Public domain | Most common free French Bible |
| French | Segond 21, NBS | Copyrighted | License needed |
| Haitian Creole | Haitian Creole Bible (Bib la, 1985/1999 revisions distributed by Bible societies) | Check license per edition — some editions from the Haitian Bible Society / Wycliffe are freely distributable for non-commercial apps, others are not | Verify licensing directly with the Société Biblique Haïtienne or American Bible Society before shipping; **do not assume public domain** |

**Recommended approach:** ship KJV + WEB (English), Louis Segond 1910 (French), and one verified-licensable Haitian Creole translation as bundled, fully offline SQLite files. Offer additional translations (NIV, ESV, etc.) as optional downloadable add-ons pulled from a licensed API (e.g. **API.Bible** — api.bible — which handles licensing per-translation and has a free tier for indie developers), cached locally once downloaded.

## APIs worth evaluating

- **API.Bible** (American Bible Society) — widest translation coverage, clear licensing terms, supports French and some Creole content depending on catalog at time of integration.
- **Bible SuperSearch API** — aggregates multiple public-domain translations.
- **ESV API** (Crossway) — if you want ESV specifically, free tier available for non-commercial use with rate limits.

Always re-check current licensing terms and catalog directly on these providers' sites before shipping, since availability changes.

## Audio Bible

- **Faith Comes By Hearing** (bible.is / FCBH) — free audio Bible API/downloads in many languages including Haitian Creole, widely used by other Bible apps, licensing is generally friendly for non-commercial/ministry-oriented apps but confirm terms for your specific use case.
- Alternative: generate narration via a TTS pipeline for translations without existing audio (lower quality, but universal coverage) — offer as a fallback, not primary.

## Commentary / study notes

- **Matthew Henry's Commentary (Concise)** — public domain, good default.
- **Treasury of Scripture Knowledge (TSK)** — public domain, excellent source for the cross-reference table in the database schema.

## Offline storage strategy

1. Bundle 1 default translation per language directly in the app binary (SQLite, compressed) so first-launch works with zero network.
2. Additional translations: downloaded as a zip → unpacked SQLite file → stored in `Application Support/Translations/`, excluded from iCloud backup (`isExcludedFromBackup = true`) since it's re-downloadable.
3. Audio: stream by default (`AVPlayer` over HTTPS), with an explicit per-chapter/book "Download" button that saves to `Application Support/Audio/{translation}/{book}/{chapter}.m4a`, also backup-excluded.
4. Total app size target: keep base install under ~150MB by shipping only 2–3 core translations bundled; everything else on-demand.
